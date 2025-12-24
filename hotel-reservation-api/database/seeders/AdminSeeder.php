<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Admin
        User::create([
            'name' => 'Admin Hotel',
            'email' => 'admin@hotel.com',
            'phone' => '081234567890',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'is_active' => true,
        ]);

        // Create Sample Customers
        User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'phone' => '081234567891',
            'password' => Hash::make('customer123'),
            'role' => 'customer',
            'is_active' => true,
        ]);

        $this->command->info('✅ Admin and sample customers created!');
        $this->command->info('   Admin: admin@hotel.com / admin123');
        $this->command->info('   Customer: john@example.com / customer123');
    }
}
