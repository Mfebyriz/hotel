<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Room extends Model
{
    protected $fillable = [
        'category_id',
        'room_number',
        'floor',
        'status',
        'description',
        'size_sqm',
    ];

    protected $casts = [
        'size_sqm' => 'decimal:2',
    ];

    public function category()
    {
        return $this->belongsTo(RoomCategory::class, 'category_id');
    }

    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }

    public function isAvailable()
    {
        return $this->status === 'available';
    }

    public function isAvailableForDates($checkIn, $checkOut)
    {
        $conflictingReservations = $this->reservations()
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

        return !$conflictingReservations && $this->isAvailable();
    }

    // Get image from category
    public function getImageUrlAttribute()
    {
        return $this->category ? $this->category->image_full_url : asset('images/placeholder-room.jpg');
    }
}