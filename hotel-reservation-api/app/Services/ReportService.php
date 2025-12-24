<?php

namespace App\Services;

use App\Models\Reservation;
use App\Models\Room;
use App\Models\RoomCategory;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ReportService
{
    /**
     * Get revenue report (from checked_out reservations)
     */
    public function getRevenueReport($startDate = null, $endDate = null)
    {
        $query = Reservation::where('status', 'checked_out');

        if ($startDate) {
            $query->whereDate('checked_out_at', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('checked_out_at', '<=', $endDate);
        }

        $totalRevenue = $query->sum('total_price');
        $totalTransactions = $query->count();
        $averageTransaction = $totalTransactions > 0 ? $totalRevenue / $totalTransactions : 0;

        // Revenue by month
        $revenueByMonth = Reservation::select(
                DB::raw('DATE_FORMAT(checked_out_at, "%Y-%m") as month'),
                DB::raw('SUM(total_price) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->where('status', 'checked_out')
            ->groupBy('month')
            ->orderBy('month', 'desc')
            ->limit(12)
            ->get();

        return [
            'total_revenue' => $totalRevenue,
            'total_transactions' => $totalTransactions,
            'average_transaction' => $averageTransaction,
            'revenue_by_month' => $revenueByMonth,
        ];
    }

    /**
     * Get reservation report
     */
    public function getReservationReport($startDate = null, $endDate = null)
    {
        $query = Reservation::query();

        if ($startDate) {
            $query->whereDate('created_at', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('created_at', '<=', $endDate);
        }

        $totalReservations = $query->count();
        $confirmedReservations = (clone $query)->where('status', 'confirmed')->count();
        $checkedInReservations = (clone $query)->where('status', 'checked_in')->count();
        $checkedOutReservations = (clone $query)->where('status', 'checked_out')->count();
        $cancelledReservations = (clone $query)->where('status', 'cancelled')->count();

        // Reservations by status
        $byStatus = Reservation::select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        // Reservations by category
        $byCategory = Reservation::join('rooms', 'reservations.room_id', '=', 'rooms.id')
            ->join('room_categories', 'rooms.category_id', '=', 'room_categories.id')
            ->select('room_categories.name', DB::raw('COUNT(*) as count'), DB::raw('SUM(reservations.total_price) as revenue'))
            ->groupBy('room_categories.name')
            ->get();

        return [
            'total_reservations' => $totalReservations,
            'confirmed_reservations' => $confirmedReservations,
            'checked_in_reservations' => $checkedInReservations,
            'checked_out_reservations' => $checkedOutReservations,
            'cancelled_reservations' => $cancelledReservations,
            'by_status' => $byStatus,
            'by_category' => $byCategory,
        ];
    }

    /**
     * Get occupancy report
     */
    public function getOccupancyReport()
    {
        $categories = RoomCategory::with('rooms')->get();

        $report = [];
        $totalRoomsAll = 0;
        $totalOccupiedAll = 0;

        foreach ($categories as $category) {
            $totalRooms = $category->rooms->count();
            $occupiedRooms = $category->rooms->where('status', 'occupied')->count();
            $availableRooms = $category->rooms->where('status', 'available')->count();
            $reservedRooms = $category->rooms->where('status', 'reserved')->count();
            $maintenanceRooms = $category->rooms->where('status', 'maintenance')->count();

            $occupancyRate = $totalRooms > 0 ? ($occupiedRooms / $totalRooms) * 100 : 0;

            $totalRoomsAll += $totalRooms;
            $totalOccupiedAll += $occupiedRooms;

            $report[] = [
                'category' => $category->name,
                'total_rooms' => $totalRooms,
                'occupied' => $occupiedRooms,
                'available' => $availableRooms,
                'reserved' => $reservedRooms,
                'maintenance' => $maintenanceRooms,
                'occupancy_rate' => round($occupancyRate, 2),
            ];
        }

        $overallOccupancyRate = $totalRoomsAll > 0 ? ($totalOccupiedAll / $totalRoomsAll) * 100 : 0;

        return [
            'by_category' => $report,
            'overall_occupancy_rate' => round($overallOccupancyRate, 2),
            'total_rooms' => $totalRoomsAll,
            'total_occupied' => $totalOccupiedAll,
        ];
    }
}