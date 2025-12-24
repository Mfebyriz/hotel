<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use App\Models\RoomCategory;
use Illuminate\Http\Request;
use Carbon\Carbon;

class RoomController extends Controller
{
    /**
     * Get all rooms (with optional filters)
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

        // Search by room number
        if ($request->has('search')) {
            $query->where('room_number', 'like', '%' . $request->search . '%');
        }

        // Filter by floor
        if ($request->has('floor')) {
            $query->where('floor', $request->floor);
        }

        $rooms = $query->get();

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
        $room = Room::with('category')->find($id);

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
     * Get all room categories
     */
    public function categories()
    {
        $categories = RoomCategory::where('is_active', true)
            ->withCount('rooms')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Search rooms
     */
    public function search(Request $request)
    {
        $query = Room::with('category');

        if ($request->has('keyword')) {
            $keyword = $request->keyword;
            $query->where(function($q) use ($keyword) {
                $q->where('room_number', 'like', '%' . $keyword . '%')
                  ->orWhereHas('category', function($q2) use ($keyword) {
                      $q2->where('name', 'like', '%' . $keyword . '%');
                  });
            });
        }

        if ($request->has('min_price')) {
            $query->whereHas('category', function($q) use ($request) {
                $q->where('base_price', '>=', $request->min_price);
            });
        }

        if ($request->has('max_price')) {
            $query->whereHas('category', function($q) use ($request) {
                $q->where('base_price', '<=', $request->max_price);
            });
        }

        $rooms = $query->get();

        return response()->json([
            'success' => true,
            'data' => $rooms
        ]);
    }

    /**
     * Check room availability for dates
     */
    public function checkAvailability(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'check_in_date' => 'required|date|after_or_equal:today',
            'check_out_date' => 'required|date|after:check_in_date',
            'category_id' => 'sometimes|exists:room_categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $checkIn = Carbon::parse($request->check_in_date);
        $checkOut = Carbon::parse($request->check_out_date);

        $query = Room::with('category')
            ->where('status', 'available');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Get rooms that don't have conflicting reservations
        $availableRooms = $query->whereDoesntHave('reservations', function($q) use ($checkIn, $checkOut) {
            $q->whereIn('status', ['confirmed', 'checked_in'])
              ->where(function($query) use ($checkIn, $checkOut) {
                  $query->whereBetween('check_in_date', [$checkIn, $checkOut])
                        ->orWhereBetween('check_out_date', [$checkIn, $checkOut])
                        ->orWhere(function($q) use ($checkIn, $checkOut) {
                            $q->where('check_in_date', '<=', $checkIn)
                              ->where('check_out_date', '>=', $checkOut);
                        });
              });
        })->get();

        return response()->json([
            'success' => true,
            'data' => [
                'check_in_date' => $checkIn->toDateString(),
                'check_out_date' => $checkOut->toDateString(),
                'available_rooms' => $availableRooms,
                'total_available' => $availableRooms->count()
            ]
        ]);
    }
}