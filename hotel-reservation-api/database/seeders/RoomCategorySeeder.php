<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\RoomCategory;

class RoomCategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Standard',
                'description' => 'Kamar standar dengan fasilitas lengkap untuk perjalanan bisnis atau liburan. Nyaman dan terjangkau.',
                'base_price' => 500000,
                'max_guests' => 2,
                'amenities' => [
                    'WiFi Gratis',
                    'TV LED 32"',
                    'AC',
                    'Kamar Mandi Dalam',
                    'Air Panas',
                    'Meja Kerja',
                    'Lemari Pakaian'
                ],
                'image_url' => 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&h=600&fit=crop',
                'is_active' => true,
            ],
            [
                'name' => 'Deluxe',
                'description' => 'Kamar deluxe dengan pemandangan kota dan fasilitas premium. Ruang lebih luas dengan kenyamanan maksimal.',
                'base_price' => 850000,
                'max_guests' => 3,
                'amenities' => [
                    'WiFi Gratis',
                    'TV LED 43"',
                    'AC',
                    'Kamar Mandi Dalam Premium',
                    'Air Panas',
                    'Mini Bar',
                    'Balkon Pribadi',
                    'City View',
                    'Sofa',
                    'Coffee Maker'
                ],
                'image_url' => 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600&fit=crop',
                'is_active' => true,
            ],
            [
                'name' => 'Suite',
                'description' => 'Suite mewah dengan ruang tamu terpisah dan fasilitas eksklusif. Pengalaman menginap terbaik untuk Anda.',
                'base_price' => 1500000,
                'max_guests' => 4,
                'amenities' => [
                    'WiFi Gratis',
                    'TV LED 55"',
                    'AC',
                    'Kamar Mandi Premium dengan Bathtub',
                    'Air Panas',
                    'Mini Bar Premium',
                    'Balkon Luas',
                    'Ocean View',
                    'Living Room',
                    'Jacuzzi',
                    'Kitchen',
                    'Dining Area',
                    'Butler Service'
                ],
                'image_url' => 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&h=600&fit=crop',
                'is_active' => true,
            ],
        ];

        foreach ($categories as $category) {
            RoomCategory::create($category);
        }

        $this->command->info('✅ Room categories created: Standard, Deluxe, Suite');
    }
}
