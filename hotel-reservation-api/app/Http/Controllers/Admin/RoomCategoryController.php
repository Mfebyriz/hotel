<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RoomCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class RoomCategoryController extends Controller
{
    /**
     * Display a listing of room categories
     */
    public function index()
    {
        try {
            $categories = RoomCategory::withCount('rooms')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $categories,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Store a newly created category
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:100',
                'description' => 'nullable|string',
                'base_price' => 'required|numeric|min:0',
                'max_guests' => 'required|integer|min:1',
                'amenities' => 'nullable|array',
                'image' => 'nullable|image|mimes:jpeg,jpg,png|max:2048',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $data = [
                'name' => $request->name,
                'description' => $request->description,
                'base_price' => $request->base_price,
                'max_guests' => $request->max_guests,
                'amenities' => $request->amenities ?? [],
                'is_active' => $request->is_active ?? true,
            ];

            // Handle image upload
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $imageName = time() . '_' . uniqid() . '.' . $image->getClientOriginalExtension();
                $path = $image->storeAs('public/categories', $imageName);
                $data['image_url'] = Storage::url($path);
            }

            $category = RoomCategory::create($data);

            return response()->json([
                'success' => true,
                'message' => 'Category created successfully',
                'data' => $category,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified category
     */
    public function show($id)
    {
        try {
            $category = RoomCategory::with('rooms')->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $category,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found',
            ], 404);
        }
    }

    /**
     * Update the specified category
     */
    public function update(Request $request, $id)
    {
        try {
            $category = RoomCategory::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:100',
                'description' => 'nullable|string',
                'base_price' => 'required|numeric|min:0',
                'max_guests' => 'required|integer|min:1',
                'amenities' => 'nullable|array',
                'image' => 'nullable|image|mimes:jpeg,jpg,png|max:2048',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $data = [
                'name' => $request->name,
                'description' => $request->description,
                'base_price' => $request->base_price,
                'max_guests' => $request->max_guests,
                'amenities' => $request->amenities ?? [],
                'is_active' => $request->is_active ?? $category->is_active,
            ];

            // Handle image upload
            if ($request->hasFile('image')) {
                // Delete old image
                if ($category->image_url) {
                    $oldPath = str_replace('/storage/', 'public/', $category->image_url);
                    Storage::delete($oldPath);
                }

                $image = $request->file('image');
                $imageName = time() . '_' . uniqid() . '.' . $image->getClientOriginalExtension();
                $path = $image->storeAs('public/categories', $imageName);
                $data['image_url'] = Storage::url($path);
            }

            $category->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Category updated successfully',
                'data' => $category,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified category
     */
    public function destroy($id)
    {
        try {
            $category = RoomCategory::findOrFail($id);

            // Check if category has rooms
            if ($category->rooms()->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete category with existing rooms',
                ], 400);
            }

            // Delete image
            if ($category->image_url) {
                $oldPath = str_replace('/storage/', 'public/', $category->image_url);
                Storage::delete($oldPath);
            }

            $category->delete();

            return response()->json([
                'success' => true,
                'message' => 'Category deleted successfully',
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Upload or update category image
     */
    public function uploadImage(Request $request, $id)
    {
        try {
            $category = RoomCategory::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'image' => 'required|image|mimes:jpeg,jpg,png|max:2048',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // Delete old image
            if ($category->image_url) {
                $oldPath = str_replace('/storage/', 'public/', $category->image_url);
                Storage::delete($oldPath);
            }

            // Upload new image
            $image = $request->file('image');
            $imageName = time() . '_' . uniqid() . '.' . $image->getClientOriginalExtension();
            $path = $image->storeAs('public/categories', $imageName);
            $imageUrl = Storage::url($path);

            $category->update(['image_url' => $imageUrl]);

            return response()->json([
                'success' => true,
                'message' => 'Image uploaded successfully',
                'data' => [
                    'image_url' => $imageUrl,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }
}