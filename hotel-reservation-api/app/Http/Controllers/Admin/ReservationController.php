<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use App\Services\ReservationService;
use Illuminate\Http\Request;

class ReservationController extends Controller
{
    protected $reservationService;

    public function __construct(ReservationService $reservationService)
    {
        $this->reservationService = $reservationService;
    }

    /**
     * Get all reservations (with filters)
     */
    public function index(Request $request)
    {
        $query = Reservation::with(['user', 'room.category']);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('check_in_date', '>=', $request->start_date);
        }

        if ($request->has('end_date')) {
            $query->whereDate('check_out_date', '<=', $request->end_date);
        }

        // Search by booking code
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('booking_code', 'like', '%' . $search . '%')
                  ->orWhereHas('user', function($q2) use ($search) {
                      $q2->where('name', 'like', '%' . $search . '%')
                         ->orWhere('email', 'like', '%' . $search . '%');
                  });
            });
        }

        // Pagination
        $perPage = $request->input('per_page', 15);
        $reservations = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $reservations
        ]);
    }

    /**
     * Get reservation detail
     */
    public function show($id)
    {
        $reservation = Reservation::with(['user', 'room.category'])
            ->find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $reservation
        ]);
    }

    /**
     * Cancel reservation (by admin)
     */
    public function cancel(Request $request, $id)
    {
        $reservation = Reservation::find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Reservation not found'
            ], 404);
        }

        try {
            $this->reservationService->cancelReservation(
                $reservation,
                $request->input('reason', 'Cancelled by admin')
            );

            return response()->json([
                'success' => true,
                'message' => 'Reservation cancelled successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Export reservations (optional)
     */
    public function export(Request $request)
    {
        // TODO: Implement CSV/Excel export
        return response()->json([
            'success' => false,
            'message' => 'Export feature not yet implemented'
        ], 501);
    }
}