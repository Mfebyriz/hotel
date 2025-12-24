<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\CustomerController;
use App\Http\Controllers\Admin\RoomCategoryController;
use App\Http\Controllers\Admin\RoomController as AdminRoomController;
use App\Http\Controllers\Admin\ReservationController as AdminReservationController;
use App\Http\Controllers\Admin\ReportController;

// PUBLIC ROUTES
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Public room browsing
Route::get('/rooms', [RoomController::class, 'index']);
Route::get('/rooms/{id}', [RoomController::class, 'show']);
Route::get('/room-categories', [RoomController::class, 'categories']);
Route::get('/rooms/search', [RoomController::class, 'search']);
Route::post('/rooms/check-availability', [RoomController::class, 'checkAvailability']);

// PROTECTED ROUTES (Require Authentication)
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);

    // CUSTOMER ROUTES
    Route::middleware('check.role:customer')->prefix('customer')->group(function () {

        // Reservations (AUTO-CONFIRMED, NO PAYMENT)
        Route::get('/reservations', [ReservationController::class, 'myReservations']);
        Route::get('/reservations/{id}', [ReservationController::class, 'show']);
        Route::post('/reservations', [ReservationController::class, 'store']);
        Route::post('/reservations/{id}/cancel', [ReservationController::class, 'cancel']);
        Route::post('/reservations/{id}/check-in', [ReservationController::class, 'checkIn']);
        Route::post('/reservations/{id}/check-out', [ReservationController::class, 'checkOut']);

        // Notifications
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::get('/notifications/unread', [NotificationController::class, 'unread']);
        Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);
    });

    // ADMIN ROUTES
    Route::middleware('check.role:admin')->prefix('admin')->group(function () {

        // Dashboard & Statistics
        Route::get('/dashboard', [DashboardController::class, 'index']);
        Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
        Route::get('/dashboard/recent-reservations', [DashboardController::class, 'recentReservations']);

        // Customer Management
        Route::get('/customers', [CustomerController::class, 'index']);
        Route::get('/customers/{id}', [CustomerController::class, 'show']);

        // Room Category Management
        Route::get('/room-categories', [RoomCategoryController::class, 'index']);
        Route::get('/room-categories/{id}', [RoomCategoryController::class, 'show']);
        Route::post('/room-categories', [RoomCategoryController::class, 'store']); // with image
        Route::post('/room-categories/{id}', [RoomCategoryController::class, 'update']); // with image
        Route::delete('/room-categories/{id}', [RoomCategoryController::class, 'destroy']);
        Route::post('/room-categories/{id}/toggle-status', [RoomCategoryController::class, 'toggleStatus']);

        // Room Management
        Route::get('/rooms', [AdminRoomController::class, 'index']);
        Route::get('/rooms/{id}', [AdminRoomController::class, 'show']);
        Route::post('/rooms', [AdminRoomController::class, 'store']);
        Route::put('/rooms/{id}', [AdminRoomController::class, 'update']);
        Route::delete('/rooms/{id}', [AdminRoomController::class, 'destroy']);
        Route::post('/rooms/{id}/status', [AdminRoomController::class, 'updateStatus']);

        // Reservation Management
        Route::get('/reservations', [AdminReservationController::class, 'index']);
        Route::get('/reservations/{id}', [AdminReservationController::class, 'show']);
        Route::post('/reservations/{id}/cancel', [AdminReservationController::class, 'cancel']);
        Route::get('/reservations/export', [AdminReservationController::class, 'export']);

        // Reports
        Route::get('/reports/revenue', [ReportController::class, 'revenue']);
        Route::get('/reports/reservations', [ReportController::class, 'reservations']);
        Route::get('/reports/occupancy', [ReportController::class, 'occupancy']);
        Route::get('/reports/export', [ReportController::class, 'export']);
    });
});

// HEALTH CHECK
Route::get('/health', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'service' => 'Hotel Reservation API',
        'version' => '1.0.0'
    ]);
});