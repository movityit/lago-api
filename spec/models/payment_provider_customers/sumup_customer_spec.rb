# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviderCustomers::SumupCustomer do
  subject(:sumup_customer) { described_class.new(attributes) }

  let(:attributes) {}

  describe "#require_provider_payment_id?" do
    it { expect(sumup_customer).not_to be_require_provider_payment_id }
  end
end
