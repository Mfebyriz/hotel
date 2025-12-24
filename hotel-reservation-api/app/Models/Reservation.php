<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Reservation extends Model
{
    protected $fillable = [
        'booking_code',
        'user_id',
        'room_id',
        'check_in_date',
        'check_out_date',
        'num_guests',
        'total_nights',
        'price_per_night',
        'total_price',
        'status',  // confirmed, checked_in, checked_out, cancelled (no pending)
        'special_requests',
        'checked_in_at',
        'checked_out_at',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'check_in_date' => 'date',
        'check_out_date' => 'date',
        'price_per_night' => 'decimal:2',
        'total_price' => 'decimal:2',
        'checked_in_at' => 'datetime',
        'checked_out_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public static function generateBookingCode()
    {
        do {
            $code = 'HTL' . strtoupper(substr(md5(uniqid(mt_rand(), true)), 0, 10));
        } while (self::where('booking_code', $code)->exists());

        return $code;
    }

    public function canCheckIn()
    {
        $today = Carbon::today();
        return $this->status === 'confirmed'
            && $this->check_in_date->isSameDay($today);
    }

    public function canCheckOut()
    {
        return $this->status === 'checked_in';
    }

    public function canCancel()
    {
        return $this->status === 'confirmed';
    }
}
