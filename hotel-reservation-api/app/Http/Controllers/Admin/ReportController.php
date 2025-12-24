<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    protected $reportService;

    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
    }

    /**
     * Get revenue report
     */
    public function revenue(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        $report = $this->reportService->getRevenueReport($startDate, $endDate);

        return response()->json([
            'success' => true,
            'data' => $report
        ]);
    }

    /**
     * Get reservation report
     */
    public function reservations(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');

        $report = $this->reportService->getReservationReport($startDate, $endDate);

        return response()->json([
            'success' => true,
            'data' => $report
        ]);
    }

    /**
     * Get occupancy report
     */
    public function occupancy()
    {
        $report = $this->reportService->getOccupancyReport();

        return response()->json([
            'success' => true,
            'data' => $report
        ]);
    }

    /**
     * Export report (optional)
     */
    public function export(Request $request)
    {
        // TODO: Implement PDF export
        return response()->json([
            'success' => false,
            'message' => 'Export feature not yet implemented'
        ], 501);
    }
}