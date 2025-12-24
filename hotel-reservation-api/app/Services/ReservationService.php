<?php

namespace App\Services;

use App\Models\Reservation;
use App\Models\Room;
use Carbon\Carbon;

class ReservationService
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Create new reservation - AUTO CONFIRMED (NO PAYMENT)
     */
    public function createReservation(array $data)
    {
        $room = Room::findOrFail($data['room_id']);

        // Check availability
        if (!$this->isRoomAvailable($room, $data['check_in_date'], $data['check_out_date'])) {
            throw new \Exception('Room is not available for selected dates');
        }

        // Calculate nights and total price
        $checkIn = Carbon::parse($data['check_in_date']);
        $checkOut = Carbon::parse($data['check_out_date']);
        $totalNights = $checkOut->diffInDays($checkIn);

        if ($totalNights < 1) {
            throw new \Exception('Minimum 1 night required');
        }

        $pricePerNight = $room->category->base_price;
        $totalPrice = $pricePerNight * $totalNights;

        // Create reservation - AUTO CONFIRMED
        $reservation = Reservation::create([
            'booking_code' => $this->generateBookingCode(),
            'user_id' => $data['user_id'],
            'room_id' => $room->id,
            'check_in_date' => $checkIn,
            'check_out_date' => $checkOut,
            'num_guests' => $data['num_guests'] ?? 1,
            'total_nights' => $totalNights,
            'price_per_night' => $pricePerNight,
            'total_price' => $totalPrice,
            'status' => 'confirmed',  // AUTO CONFIRMED - NO PAYMENT NEEDED
            'special_requests' => $data['special_requests'] ?? null,
        ]);

        // Update room status
        $room->update(['status' => 'reserved']);

        // Send notification
        $this->notificationService->createNotification(
            $reservation->user,
            'Reservasi Berhasil',
            "Reservasi Anda dengan kode {$reservation->booking_code} berhasil dikonfirmasi! Total: Rp " . number_format($totalPrice, 0, ',', '.') . ". Pembayaran dapat dilakukan saat check-in di hotel.",
            'reservation_confirmed',
            $reservation->id
        );

        return $reservation;
    }

    /**
     * Check if room is available for dates
     */
    public function isRoomAvailable(Room $room, $checkIn, $checkOut): bool
    {
        $conflictingReservations = Reservation::where('room_id', $room->id)
            ->whereIn('status', ['confirmed', 'checked_in'])
            ->where(function ($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in_date', [$checkIn, $checkOut])
                    ->orWhereBetween('check_out_date', [$checkIn, $checkOut])
                    ->orWhere(function ($q) use ($checkIn, $checkOut) {
                        $q->where('check_in_date', '<=', $checkIn)
                          ->where('check_out_date', '>=', $checkOut);
                    });
            })
            ->exists();

        return !$conflictingReservations && $room->status === 'available';
    }

    /**
     * Check-in
     */
    public function checkIn(Reservation $reservation)
    {
        if ($reservation->status !== 'confirmed') {
            throw new \Exception('Cannot check in. Reservation must be confirmed first.');
        }

        $today = Carbon::today();
        if (!$reservation->check_in_date->isSameDay($today)) {
            throw new \Exception('Check-in date must be today.');
        }

        $reservation->update([
            'status' => 'checked_in',
            'checked_in_at' => now(),
        ]);

        $reservation->room->update(['status' => 'occupied']);

        $this->notificationService->createNotification(
            $reservation->user,
            'Check-in Berhasil',
            "Selamat datang! Check-in untuk reservasi {$reservation->booking_code} berhasil. Selamat menikmati penginapan!",
            'checked_in',
            $reservation->id
        );

        return $reservation;
    }

    /**
     * Check-out
     */
    public function checkOut(Reservation $reservation)
    {
        if ($reservation->status !== 'checked_in') {
            throw new \Exception('Cannot check out. Invalid reservation status.');
        }

        $reservation->update([
            'status' => 'checked_out',
            'checked_out_at' => now(),
        ]);

        $reservation->room->update(['status' => 'available']);

        $this->notificationService->createNotification(
            $reservation->user,
            'Check-out Berhasil',
            "Terima kasih telah menginap di hotel kami! Check-out untuk reservasi {$reservation->booking_code} berhasil. Semoga dapat berkunjung kembali!",
            'checked_out',
            $reservation->id
        );

        return $reservation;
    }

    /**
     * Cancel reservation
     */
    public function cancelReservation(Reservation $reservation, string $reason = null)
    {
        if (!$reservation->canCancel()) {
            throw new \Exception('Cannot cancel reservation with current status.');
        }

        $reservation->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
            'cancellation_reason' => $reason,
        ]);

        $reservation->room->update(['status' => 'available']);

        $this->notificationService->createNotification(
            $reservation->user,
            'Reservasi Dibatalkan',
            "Reservasi {$reservation->booking_code} telah dibatalkan.",
            'reservation_cancelled',
            $reservation->id
        );

        return $reservation;
    }

    /**
     * Generate unique booking code
     */
    private function generateBookingCode(): string
    {
        do {
            $code = 'HTL' . strtoupper(substr(md5(uniqid(mt_rand(), true)), 0, 10));
        } while (Reservation::where('booking_code', $code)->exists());

        return $code;
    }
}