require 'httparty'
require "json"
require 'openssl'
require 'base64'



# $data = array('receiver_id' => $receiver_id
#     , 'notification_token' => $notification_token
#     , 'hash' => $hash);



# response = HTTParty.get('https://khipu.com/api/1.3/getPaymentNotification')



# data = JSON.parse(response.body)


# v = data['error']['type']

# if v == 'invalid-request'
# 	puts 'conchetumare'
# end

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
		#tengo que reconocer los pagos
		response = HTTParty.get("https://khipu.com/api/1.3/getPaymentNotification",
		    :query => { :receiver_id => receiver_id, :notification_token => notification_token, :hash => hash })

		datos_pago_khipu = JSON.parse(response.body)
	else
		
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

# {"error":{"type":"invalid-request","message":"notification_token no puede estar vacío"}}

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