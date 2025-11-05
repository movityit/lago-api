# frozen_string_literal: true

module Mutations
  module PaymentProviders
    module Sumup
      class Create < Base
        REQUIRED_PERMISSION = "organization:integrations:create"

        graphql_name "AddSumupPaymentProvider"
        description "Add or update Sumup payment provider"

        input_object_class Types::PaymentProviders::SumupInput

        type Types::PaymentProviders::Sumup
      end
    end
  end
end
