<?php

namespace App\Http\Requests\Reservation;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class CreateReservationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'room_id' => ['required', 'exists:rooms,id'],
            'check_in_date' => ['required', 'date', 'after_or_equal:today'],
            'check_out_date' => ['required', 'date', 'after:check_in_date'],
            'num_guests' => ['required', 'integer', 'min:1'],
            'special_requests' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'room_id.required' => 'Kamar harus dipilih',
            'room_id.exists' => 'Kamar tidak ditemukan',
            'check_in_date.required' => 'Tanggal check-in harus diisi',
            'check_in_date.after_or_equal' => 'Tanggal check-in tidak boleh kurang dari hari ini',
            'check_out_date.required' => 'Tanggal check-out harus diisi',
            'check_out_date.after' => 'Tanggal check-out harus setelah check-in',
            'num_guests.required' => 'Jumlah tamu harus diisi',
            'num_guests.min' => 'Jumlah tamu minimal 1',
            'special_requests.max' => 'Permintaan khusus maksimal 1000 karakter',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'message' => 'Validasi gagal',
            'errors' => $validator->errors(),
        ], 422));
    }
}