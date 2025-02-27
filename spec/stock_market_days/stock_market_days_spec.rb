require 'spec_helper'
require 'stock_market_days'

describe StockMarketDays do

  context 'included in a class' do
    let(:dummy_class) do
      class Dummy
        include StockMarketDays

        def is_market_day_delegator(date)
          is_market_day?(date)
        end
      end

      Dummy.new
    end

    context '#is_market_day?' do
      subject { dummy_class.is_market_day_delegator(date) }
      let(:date) { Date.new(2019,12,30) }

      it { is_expected.to be_truthy }
    end
  end

  context '#is_market_day?' do
    subject { described_class.is_market_day?(date) }

    context 'is a market day' do
      let(:date) { Date.new(2022,1,5) }

      it { is_expected.to be_truthy }
    end

    context 'is Martin Luther King Day' do
      let(:date) { Date.new(2022,1,17) }

      it { is_expected.to be_falsey }
    end

    context 'is Presidents Day' do
      let(:date) { Date.new(2023,2,20) }

      it { is_expected.to be_falsey }
    end

    context 'is Juneteenth' do
      let(:dates) do
        [
          Date.new(2022,6,19), # Sunday
          Date.new(2022,6,20), # Monday (holiday falls on Sunday)
          Date.new(2022,6,19), # Wednesday
          Date.new(2027,6,18)  # Friday (holiday falls on Saturday)
        ]
      end

      it 'reports market closed on the holiday, or nearest Friday/Monday if on the weekend' do
        dates.each do |market_closed_day|
          expect(described_class.is_market_day?(market_closed_day)).to be_falsey
        end
      end
    end

    context 'is Thanksgiving' do
      let(:date) { Date.new(2023,11,23) }

      it { is_expected.to be_falsey }
    end

    context 'is Christmas (observed)' do
      let(:date) { Date.new(2027,12,24) }

      it { is_expected.to be_falsey }
    end
  end

  context '#market_days_between' do
    subject { described_class.market_days_between(begin_date, end_date) }

    context 'pure trading days' do
      let(:begin_date) { Date.new(2020,4,20) }
      let(:end_date) { Date.new(2020,5,27) }

      it { is_expected.to eql(26) }
    end

    context 'end date on a weekend' do
      let(:begin_date) { Date.new(2020,4,20) }
      let(:end_date) { Date.new(2020,5,31) }

      it { is_expected.to eql(28) }
    end

    context 'end date is less than begin date' do
      let(:begin_date) { Date.new(2020,5,31) }
      let(:end_date) { Date.new(2020,4,20) }

      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end

  context '#market_days_from' do
    subject { described_class.market_days_from(begin_date, count_days) }

    context 'on a holiday weekend' do
      context '0 days' do
        let(:begin_date) { Date.new(2019,9,1) }
        let(:count_days) { 0 }

        it { is_expected.to eql(Date.new(2019,8,30)) } # returns most recent trading day
      end

      context '1 day' do
        let(:begin_date) { Date.new(2019,9,1) }
        let(:count_days) { 1 }

        it { is_expected.to eql(Date.new(2019,9,3)) } # returns next trading day
      end

      context '2 days' do
        let(:begin_date) { Date.new(2019,9,1) }
        let(:count_days) { 2 }

        it { is_expected.to eql(Date.new(2019,9,4)) }
      end
    end

    context 'over a weekend' do
      context '0 days' do
        let(:begin_date) { Date.new(2019,8,30) }
        let(:count_days) { 0 }

        it { is_expected.to eql(Date.new(2019,8,30)) }
      end

      context '1 day' do
        let(:begin_date) { Date.new(2019,8,30) }
        let(:count_days) { 1 }

        it { is_expected.to eql(Date.new(2019,9,3)) }
      end

      context '2 days' do
        let(:begin_date) { Date.new(2019,8,30) }
        let(:count_days) { 2 }

        it { is_expected.to eql(Date.new(2019,9,4)) }
      end
    end

    context 'midweek' do
      let(:begin_date) { Date.new(2019,9,3) }
      let(:count_days) { 2 }

      it { is_expected.to eql(Date.new(2019,9,5)) }
    end
  end

  context '#next_market_day' do
    subject { described_class.next_market_day(from_date) }

    context 'on a holiday weekend' do
      let(:from_date) { Date.new(2019,9,1) }

      it { is_expected.to eql(Date.new(2019,9,3)) }
    end

    context 'on a regular trading day' do
      let(:from_date) { Date.new(2019,9,5) }

      it { is_expected.to eql(Date.new(2019,9,6)) }
    end

    context 'on a Friday' do
      let(:from_date) { Date.new(2019,8,30) }

      it { is_expected.to eql(Date.new(2019,9,3)) }
    end
  end

  context '#previous_market_day' do
    subject { described_class.previous_market_day(before_date) }

    context 'on a weekend' do
      let(:before_date) { Date.new(2023,05,21) }

      it { is_expected.to eql(Date.new(2023,05,19)) }
    end

    context 'on a Monday' do
      let(:before_date) { Date.new(2023,05,22) }

      it { is_expected.to eql(Date.new(2023,05,19)) }
    end

    context 'on a trading day after a holiday' do
      let(:before_date) { Date.new(2023,06,20) }

      it { is_expected.to eql(Date.new(2023,06,16)) }
    end

  end

end