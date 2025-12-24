<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use App\Models\User;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Get dashboard data (all in one)
     */
    public function index()
    {
        $stats = $this->getStats();
        $recentReservations = $this->getRecentReservations();
        $monthlyRevenue = $this->getMonthlyRevenue();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => $stats,
                'recent_reservations' => $recentReservations,
                'monthly_revenue' => $monthlyRevenue,
            ]
        ]);
    }

    /**
     * Get statistics
     */
    public function getStats()
    {
        $totalReservations = Reservation::count();
        $totalRevenue = Reservation::where('status', 'checked_out')->sum('total_price');
        $totalCustomers = User::where('role', 'customer')->count();

        // Occupancy rate
        $totalRooms = Room::count();
        $occupiedRooms = Room::where('status', 'occupied')->count();
        $occupancyRate = $totalRooms > 0 ? ($occupiedRooms / $totalRooms) * 100 : 0;

        // Trends (compare with last month)
        $currentMonth = now()->startOfMonth();
        $lastMonth = now()->subMonth()->startOfMonth();

        $currentMonthReservations = Reservation::whereDate('created_at', '>=', $currentMonth)->count();
        $lastMonthReservations = Reservation::whereDate('created_at', '>=', $lastMonth)
            ->whereDate('created_at', '<', $currentMonth)->count();

        $reservationTrend = $lastMonthReservations > 0
            ? (($currentMonthReservations - $lastMonthReservations) / $lastMonthReservations) * 100
            : 0;

        return [
            'total_reservations' => $totalReservations,
            'total_revenue' => $totalRevenue,
            'total_customers' => $totalCustomers,
            'occupancy_rate' => round($occupancyRate, 2),
            'trends' => [
                'reservations' => round($reservationTrend, 1),
            ]
        ];
    }

    /**
     * Get recent reservations
     */
    public function getRecentReservations($limit = 5)
    {
        $reservations = Reservation::with(['user', 'room.category'])
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();

        return $reservations;
    }

    /**
     * Get monthly revenue (last 6 months)
     */
    private function getMonthlyRevenue()
    {
        $monthlyData = Reservation::select(
                DB::raw('DATE_FORMAT(checked_out_at, "%Y-%m") as month'),
                DB::raw('SUM(total_price) as revenue'),
                DB::raw('COUNT(*) as count')
            )
            ->where('status', 'checked_out')
            ->whereNotNull('checked_out_at')
            ->groupBy('month')
            ->orderBy('month', 'desc')
            ->limit(6)
            ->get()
            ->reverse()
            ->values();

        return $monthlyData;
    }
}
