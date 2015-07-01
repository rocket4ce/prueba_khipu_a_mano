class PagosController < ApplicationController
	require 'httparty'
	require "json"
	require 'openssl'
	require 'base64'
	
	before_action :concatenated, only: [:pago]
	before_action :hmac_sha256, only: [:pago]
	before_action :params_kiphu, only: [:pago]

	def pago (params_kiphu)
		
		receiver_id = '1234'
		secret = 'abcd'
		concatena = concatenated(receiver_id: receiver_id, secret: secret)
		hash = hmac_sha256(secret, concatena)
		
		if params_kiphu[:receiver_id] == receiver_id
			notification_token = params_kiphu[:notification_token]
			
			#tengo que reconocer los datos que me envio kiphu
			response = HTTParty.get("https://khipu.com/api/1.3/getPaymentNotification",
			    :query => { :receiver_id => receiver_id, :notification_token => notification_token, :hash => hash })

			#obtengo los datos del pago ejemplo
			#//////////////////////////////////////////////////////////////////
			# {
			#     "notification_token"=>"j8kPBHaPNy3PkCh...hhLvQbenpGjA",
			#     "receiver_id"=>ID_DEL_COBRADOR,
			#     "subject"=>"Motivo del cobro",
			#     "amount"=>"100",
			#     "custom"=>"",
			#     "transaction_id"=>"MTX_123123",
			#     "payment_id"=>"qpclzun1nlej",
			#     "currency"=>"CLP",
			#     "payer_email"=>"ejemplo@gmail.com"
			# }

			datos_pago_khipu = JSON.parse(response.body)

			error = datos_pago_khipu['error']['type']
			if error == 'invalid-request'
				puts "la cague"

			elsif datos_pago_khipu['amount'].to_i == 4500
				#haz algo acá
			end
		else
			# Y si no el recevier_id no es identico al mio es de otra persona
		end

	end

	private
		def concatenated(params)
		    params.collect { |k, v| k.to_s + '=' + v.to_s }.join('&')
		end

		def hmac_sha256(secret, data)
		    OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, data).unpack('H*').first
		end

		def params_kiphu
			permit.params(:api_version, :notification_token)
		end



	# $receiver_id =  '<id de cobrador>';
	# $secret =  '<id de cobrador>';
	# $notification_token = $_POST['notification_token'];
	# $api_version = $_POST['api_version'];

	# if($api_version != '1.3'){
	#     exit('not supported');
	# }

	# $concatenated = "receiver_id=$receiver_id&notification_token=$notification_token";

	# $hash = hash_hmac('sha256', $concatenated , $secret);

	# $url = 'https://khipu.com/api/1.3/getPaymentNotification';

	# $ch = curl_init();
	# curl_setopt($ch, CURLOPT_URL, $url);
	# curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	# curl_setopt($ch, CURLOPT_POST, true);


	# $data = array('receiver_id' => $receiver_id
	#     , 'notification_token' => $notification_token
	#     , 'hash' => $hash);

	#     curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
	#     $output = curl_exec($ch);
	#     $info = curl_getinfo($ch);
	#     curl_close($ch);
	# $notification = json_decode($output);
	# // revisamos que correspondan una solicitud de pago generada por nosotros

	# if($notification->receiver_id != $receiver_id){
	#   exit('no es para mi');
	# }


	# $orden = obtengoOrdenDesdeElBackend($notification->transaction_id);

	# if($notification->amount == $orden->amount){
	#     // procesamos el pago
	# }
end