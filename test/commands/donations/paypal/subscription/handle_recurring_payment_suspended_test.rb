require_relative '../../test_base'

class Donations::Paypal::Subscription::HandleRecurringPaymentSuspendedTest < Donations::TestBase
  test "ignores unknown subscription" do
    payload = { "recurring_payment_id" => SecureRandom.uuid }

    Donations::Paypal::Subscription::HandleRecurringPaymentSuspended.(payload)

    refute Donations::Subscription.exists?
  end

  test "changes status to canceled for known subscription" do
    subscription = create :donations_subscription, provider: :paypal, status: :active
    payload = { "recurring_payment_id" => subscription.external_id }

    refute subscription.canceled?

    Donations::Paypal::Subscription::HandleRecurringPaymentSuspended.(payload)

    assert subscription.reload.canceled?
  end
end