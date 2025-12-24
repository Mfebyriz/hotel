<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RoomController extends Controller
{
    /**
     * Get all rooms
     */
    public function index(Request $request)
    {
        $query = Room::with('category');

        // Filter by category
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Search
        if ($request->has('search')) {
            $query->where('room_number', 'like', '%' . $request->search . '%');
        }

        $rooms = $query->orderBy('room_number')->get();

        return response()->json([
            'success' => true,
            'data' => $rooms
        ]);
    }

    /**
     * Get room detail
     */
    public function show($id)
    {
        $room = Room::with(['category', 'reservations' => function($q) {
            $q->whereIn('status', ['confirmed', 'checked_in'])
              ->orderBy('check_in_date');
        }])->find($id);

        if (!$room) {
            return response()->json([
                'success' => false,
                'message' => 'Room not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $room
        ]);
    }

    /**
     * Create new room
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category_id' => 'required|exists:room_categories,id',
            'room_number' => 'required|string|max:20|unique:rooms,room_number',
            'floor' => 'nullable|integer',
            'description' => 'nullable|string',
            'size_sqm' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $room = Room::create([
            'category_id' => $request->category_id,
            'room_number' => $request->room_number,
            'floor' => $request->floor,
            'status' => 'available',
            'description' => $request->description,
            'size_sqm' => $request->size_sqm,
        ]);

        $room->load('category');

        return response()->json([
            'success' => true,
            'message' => 'Room created successfully',
            'data' => $room
        ], 201);
    }

    /**
     * Update room
     */
    public function update(Request $request, $id)
    {
        $room = Room::find($id);

        if (!$room) {
            return response()->json([
                'success' => false,
                'message' => 'Room not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'category_id' => 'sometimes|required|exists:room_categories,id',
            'room_number' => 'sometimes|required|string|max:20|unique:rooms,room_number,' . $id,
            'floor' => 'nullable|integer',
            'description' => 'nullable|string',
            'size_sqm' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $room->update($request->only([
            'category_id', 'room_number', 'floor', 'description', 'size_sqm'
        ]));

        $room->load('category');

        return response()->json([
            'success' => true,
            'message' => 'Room updated successfully',
            'data' => $room
        ]);
    }

    /**
     * Delete room
     */
    public function destroy($id)
    {
        $room = Room::find($id);

        if (!$room) {
            return response()->json([
                'success' => false,
                'message' => 'Room not found'
            ], 404);
        }

        // Check if room has active reservations
        $hasActiveReservations = $room->reservations()
            ->whereIn('status', ['confirmed', 'checked_in'])
            ->exists();

        if ($hasActiveReservations) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete room with active reservations'
            ], 400);
        }

        $room->delete();

        return response()->json([
            'success' => true,
            'message' => 'Room deleted successfully'
        ]);
    }

    /**
     * Update room status
     */
    public function updateStatus(Request $request, $id)
    {
        $room = Room::find($id);

        if (!$room) {
            return response()->json([
                'success' => false,
                'message' => 'Room not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:available,occupied,maintenance,reserved',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $room->status = $request->status;
        $room->save();

        return response()->json([
            'success' => true,
            'message' => 'Room status updated successfully',
            'data' => $room
        ]);
    }
}