<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Room;
use App\Models\RoomCategory;

class RoomSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $standard = RoomCategory::where('name', 'Standard')->first();
        $deluxe = RoomCategory::where('name', 'Deluxe')->first();
        $suite = RoomCategory::where('name', 'Suite')->first();

        $rooms = [
            // Standard Rooms - Floor 1
            ['category_id' => $standard->id, 'room_number' => '101', 'floor' => 1, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '102', 'floor' => 1, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '103', 'floor' => 1, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '104', 'floor' => 1, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '105', 'floor' => 1, 'size_sqm' => 25],

            // Standard Rooms - Floor 2
            ['category_id' => $standard->id, 'room_number' => '201', 'floor' => 2, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '202', 'floor' => 2, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '203', 'floor' => 2, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '204', 'floor' => 2, 'size_sqm' => 25],
            ['category_id' => $standard->id, 'room_number' => '205', 'floor' => 2, 'size_sqm' => 25],

            // Deluxe Rooms - Floor 3
            ['category_id' => $deluxe->id, 'room_number' => '301', 'floor' => 3, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '302', 'floor' => 3, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '303', 'floor' => 3, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '304', 'floor' => 3, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '305', 'floor' => 3, 'size_sqm' => 35],

            // Deluxe Rooms - Floor 4
            ['category_id' => $deluxe->id, 'room_number' => '401', 'floor' => 4, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '402', 'floor' => 4, 'size_sqm' => 35],
            ['category_id' => $deluxe->id, 'room_number' => '403', 'floor' => 4, 'size_sqm' => 35],

            // Suite Rooms - Floor 5
            ['category_id' => $suite->id, 'room_number' => '501', 'floor' => 5, 'size_sqm' => 60],
            ['category_id' => $suite->id, 'room_number' => '502', 'floor' => 5, 'size_sqm' => 60],
            ['category_id' => $suite->id, 'room_number' => '503', 'floor' => 5, 'size_sqm' => 65],
            ['category_id' => $suite->id, 'room_number' => '504', 'floor' => 5, 'size_sqm' => 70, 'description' => 'Presidential Suite with panoramic view'],
        ];

        foreach ($rooms as $room) {
            Room::create(array_merge($room, [
                'status' => 'available',
            ]));
        }

        $this->command->info('✅ ' . count($rooms) . ' rooms created across 5 floors!');
        $this->command->info('   Standard: 10 rooms');
        $this->command->info('   Deluxe: 8 rooms');
        $this->command->info('   Suite: 4 rooms');
    }
}
