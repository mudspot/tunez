defmodule Tunez.Security.Vault do
  def encrypt!(data), do: encrypt(data, true)
  def decrypt!(data), do: decrypt(data, true)
  
  @doc """
  Encrypts the given plaintext.

  ## Parameters
    - plaintext: The text to be encrypted.
    - uri_encode: Boolean flag to determine if the result should be URI encoded.

  ## Returns
    A Base64 encoded string (optionally URI encoded) containing the IV and ciphertext.
  """
  def encrypt(plaintext, uri_encode \\ false) do
    iv = :crypto.strong_rand_bytes(16)
    key = compute_key()
    plaintext_bytes = pad(plaintext)
    ciphertext = :crypto.crypto_one_time(:aes_256_cbc, key, iv, plaintext_bytes, true)

    encrypted = (iv <> ciphertext) |> Base.encode64()
    if uri_encode, do: encrypted |> URI.encode_www_form(), else: encrypted
  end

  @doc """
  Decrypts the given encoded text.

  ## Parameters
    - encoded: The Base64 encoded string (possibly URI encoded) to be decrypted.
    - uri_decode: Boolean flag to determine if the input needs to be URI decoded first.

  ## Returns
    The decrypted plaintext.
  """
  def decrypt(encoded, uri_decode \\ false) do
    <<iv::binary-16, ciphertext::binary>> =
      if uri_decode do
        encoded |> URI.decode_www_form()
      else
        encoded
      end
      |> Base.decode64!()

    key = compute_key()
    plaintext_bytes = :crypto.crypto_one_time(:aes_256_cbc, key, iv, ciphertext, false)
    unpad(plaintext_bytes)
  end

  defp pad(data) do
    block_size = 16
    padding_size = block_size - rem(byte_size(data), block_size)
    padding = :binary.copy(<<padding_size>>, padding_size)
    data <> padding
  end

  defp unpad(data) do
    padding_size = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - padding_size)
  end

  defp compute_key() do
    %{secret_key_base: secret} =
      Application.fetch_env!(:tunez, TunezWeb.Endpoint) |> Enum.into(%{})

    secret
    |> String.pad_trailing(32, <<0>>)
    |> String.slice(0, 32)
    |> String.to_charlist()
  end
end