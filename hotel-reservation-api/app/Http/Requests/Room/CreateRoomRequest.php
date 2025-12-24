<?php

namespace App\Http\Requests\Room;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class CreateRoomRequest extends FormRequest
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
        $roomId = $this->route('room') ?? null;

        return [
            'category_id' => ['required', 'exists:room_categories,id'],
            'room_number' => ['required', 'string', 'max:20', 'unique:rooms,room_number,' . $roomId],
            'floor' => ['nullable', 'integer', 'min:1'],
            'status' => ['required', 'in:available,occupied,maintenance,reserved'],
            'description' => ['nullable', 'string', 'max:1000'],
            'size_sqm' => ['nullable', 'numeric', 'min:1'],
        ];
    }

    public function messages(): array
    {
        return [
            'category_id.required' => 'Kategori harus dipilih',
            'category_id.exists' => 'Kategori tidak ditemukan',
            'room_number.required' => 'Nomor kamar harus diisi',
            'room_number.unique' => 'Nomor kamar sudah digunakan',
            'status.required' => 'Status harus dipilih',
            'status.in' => 'Status tidak valid',
            'floor.min' => 'Lantai minimal 1',
            'size_sqm.min' => 'Luas kamar minimal 1 m²',
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
