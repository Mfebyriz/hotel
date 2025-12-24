<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RoomCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class RoomCategoryController extends Controller
{
    /**
     * Get all categories
     */
    public function index(Request $request)
    {
        $query = RoomCategory::withCount('rooms');

        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        if ($request->has('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        $categories = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Get category detail
     */
    public function show($id)
    {
        $category = RoomCategory::withCount('rooms')
            ->with('rooms')
            ->find($id);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $category
        ]);
    }

    /**
     * Create new category (WITH IMAGE)
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100|unique:room_categories,name',
            'description' => 'nullable|string',
            'base_price' => 'required|numeric|min:0',
            'max_guests' => 'required|integer|min:1',
            'amenities' => 'nullable|array',
            'amenities.*' => 'string',
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Upload image
        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('categories', 'public');
        }

        $category = RoomCategory::create([
            'name' => $request->name,
            'description' => $request->description,
            'base_price' => $request->base_price,
            'max_guests' => $request->max_guests,
            'amenities' => $request->amenities ?? [],
            'image_url' => $imagePath,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Category created successfully',
            'data' => $category
        ], 201);
    }

    /**
     * Update category (WITH IMAGE)
     */
    public function update(Request $request, $id)
    {
        $category = RoomCategory::find($id);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:100|unique:room_categories,name,' . $id,
            'description' => 'nullable|string',
            'base_price' => 'sometimes|required|numeric|min:0',
            'max_guests' => 'sometimes|required|integer|min:1',
            'amenities' => 'nullable|array',
            'amenities.*' => 'string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Update image if provided
        if ($request->hasFile('image')) {
            // Delete old image
            if ($category->image_url && Storage::disk('public')->exists($category->image_url)) {
                Storage::disk('public')->delete($category->image_url);
            }

            $category->image_url = $request->file('image')->store('categories', 'public');
        }

        $category->update($request->only([
            'name', 'description', 'base_price', 'max_guests'
        ]));

        if ($request->has('amenities')) {
            $category->amenities = $request->amenities;
            $category->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Category updated successfully',
            'data' => $category
        ]);
    }

    /**
     * Delete category
     */
    public function destroy($id)
    {
        $category = RoomCategory::withCount('rooms')->find($id);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found'
            ], 404);
        }

        if ($category->rooms_count > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete category with existing rooms'
            ], 400);
        }

        // Delete image
        if ($category->image_url && Storage::disk('public')->exists($category->image_url)) {
            Storage::disk('public')->delete($category->image_url);
        }

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted successfully'
        ]);
    }

    /**
     * Toggle category status
     */
    public function toggleStatus($id)
    {
        $category = RoomCategory::find($id);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found'
            ], 404);
        }

        $category->is_active = !$category->is_active;
        $category->save();

        return response()->json([
            'success' => true,
            'message' => 'Category status updated successfully',
            'data' => $category
        ]);
    }
}