<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoomCategoryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'base_price' => $this->base_price,
            'base_price_formatted' => 'Rp ' . number_format($this->base_price, 0, ',', '.'),
            'max_guests' => $this->max_guests,
            'amenities' => $this->amenities ?? [],
            'image_url' => $this->image_url,
            'is_active' => $this->is_active,
            'available_rooms_count' => $this->whenLoaded('rooms', function () {
                return $this->rooms->where('status', 'available')->count();
            }),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
