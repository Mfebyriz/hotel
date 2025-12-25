<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\CustomerController;
use App\Http\Controllers\Admin\RoomController as AdminRoomController;
use App\Http\Controllers\Admin\RoomCategoryController;
use App\Http\Controllers\Admin\ReservationController as AdminReservationController;
use App\Http\Controllers\Admin\ReportController;

// Public Routes (No Auth Required)
Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('register', [AuthController::class, 'register']);
});

// Protected Routes (Auth Required)
Route::middleware('auth:sanctum')->group(function () {

    // Auth Routes
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });

    // Room Routes (Customer)
    Route::get('rooms', [RoomController::class, 'index']);
    Route::get('rooms/{room}', [RoomController::class, 'show']);
    Route::get('rooms/available', [RoomController::class, 'checkAvailability']);
    Route::get('room-categories', [RoomController::class, 'categories']);

    // Customer Reservation Routes
    Route::prefix('customer')->group(function () {
        Route::get('reservations', [ReservationController::class, 'index']);
        Route::post('reservations', [ReservationController::class, 'store']);
        Route::get('reservations/{reservation}', [ReservationController::class, 'show']);
        Route::post('reservations/{reservation}/cancel', [ReservationController::class, 'cancel']);
    });

    // Notification Routes
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::post('read-all', [NotificationController::class, 'markAllAsRead']);
        Route::delete('{notification}', [NotificationController::class, 'destroy']);
    });

    // Admin Routes (Role: admin)
    Route::middleware('check.role:admin')->prefix('admin')->group(function () {

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index']);

        // Customer Management
        Route::get('customers', [CustomerController::class, 'index']);
        Route::get('customers/{user}', [CustomerController::class, 'show']);

        // Room Category Management
        Route::apiResource('room-categories', RoomCategoryController::class);
        Route::post('room-categories/{category}/upload-image', [RoomCategoryController::class, 'uploadImage']);

        // Room Management
        Route::apiResource('rooms', AdminRoomController::class);
        Route::put('rooms/{room}/status', [AdminRoomController::class, 'updateStatus']);

        // Reservation Management
        Route::get('reservations', [AdminReservationController::class, 'index']);
        Route::get('reservations/{reservation}', [AdminReservationController::class, 'show']);
        Route::post('reservations/{reservation}/check-in', [AdminReservationController::class, 'checkIn']);
        Route::post('reservations/{reservation}/check-out', [AdminReservationController::class, 'checkOut']);
        Route::post('reservations/{reservation}/cancel', [AdminReservationController::class, 'cancel']);

        // Reports
        Route::get('reports', [ReportController::class, 'index']);
        Route::get('reports/revenue', [ReportController::class, 'revenue']);
        Route::get('reports/occupancy', [ReportController::class, 'occupancy']);
    });
});