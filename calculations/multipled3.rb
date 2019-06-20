require 'json'

def lambda_handler(event:, context:)
  { value: (event["value"].to_f * 3).round(5) }
end
