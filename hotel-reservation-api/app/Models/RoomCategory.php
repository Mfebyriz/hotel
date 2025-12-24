<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoomCategory extends Model
{
    protected $fillable = [
        'name',
        'description',
        'base_price',
        'max_guests',
        'amenities',
        'image_url',  // Single image per category
        'is_active',
    ];

    protected $casts = [
        'base_price' => 'decimal:2',
        'amenities' => 'array',
        'is_active' => 'boolean',
    ];

    protected $appends = ['image_full_url'];

    public function rooms()
    {
        return $this->hasMany(Room::class, 'category_id');
    }

    public function availableRooms()
    {
        return $this->rooms()->where('status', 'available');
    }

    public function getImageFullUrlAttribute()
    {
        if ($this->image_url) {
            // If starts with http/https, return as is
            if (str_starts_with($this->image_url, 'http')) {
                return $this->image_url;
            }
            // Otherwise, prepend storage URL
            return asset('storage/' . $this->image_url);
        }
        return asset('images/placeholder-room.jpg');
    }
}
