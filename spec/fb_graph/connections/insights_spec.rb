require File.join(File.dirname(__FILE__), '../../spec_helper')

describe FbGraph::Connections::Insights, '#insights' do

  context 'when included by FbGraph::Page' do
    before do
      fake_json(:get, 'FbGraph/insights', 'pages/insights/FbGraph_public')
      fake_json(:get, 'FbGraph/insights?access_token=access_token', 'pages/insights/FbGraph_private')
    end

    context 'when no access_token given' do
      it 'should raise FbGraph::Unauthorized' do
        lambda do
          FbGraph::Page.new('FbGraph').insights
        end.should raise_exception(FbGraph::Unauthorized)
      end
    end

    context 'when access_token is given' do
      it 'should return insights as FbGraph::Insight' do
        insights = FbGraph::Page.new('FbGraph').insights(:access_token => 'access_token')
        insights.class.should == FbGraph::Connection
        insights.first.should == FbGraph::Insight.new(
          '117513961602338/insights/page_fan_adds_unique/day',
          :access_token => 'access_token',
          :name => 'page_fan_adds_unique',
          :description => 'Daily New Likes of your Page (Unique Users)',
          :period => 'day',
          :values => [{
            :value => 1,
            :end_time => '2010-11-27T08:00:00+0000'
          }]
        )
        insights.each do |insight|
          insight.should be_instance_of(FbGraph::Insight)
        end
      end
    end

    context 'when metrics is given' do
      before do
        fake_json(:get, 'FbGraph/insights/page_like_adds?access_token=access_token', 'pages/insights/page_like_adds/FbGraph_private')
        fake_json(:get, 'FbGraph/insights/page_like_adds/day?access_token=access_token', 'pages/insights/page_like_adds/day/FbGraph_private')
      end

      it 'should treat metrics as connection scope' do
        insights = FbGraph::Page.new('FbGraph').insights(:access_token => 'access_token', :metrics => :page_like_adds)
        insights.options.should == {
          :connection_scope => 'page_like_adds',
          :access_token => 'access_token'
        }
        insights.first.should == FbGraph::Insight.new(
          '117513961602338/insights/page_like_adds/day',
          :access_token => 'access_token',
          :name => 'page_like_adds',
          :description => 'Daily Likes of your Page\'s content (Total Count)',
          :period => 'day',
          :values => [{
            :value => 0,
            :end_time => '2010-12-09T08:00:00+0000'
          }, {
            :value => 0,
            :end_time => '2010-12-10T08:00:00+0000'
          }, {
            :value => 0,
            :end_time => '2010-12-11T08:00:00+0000'
          }]
        )
      end

      it 'should support period also' do
        insights = FbGraph::Page.new('FbGraph').insights(:access_token => 'access_token', :metrics => :page_like_adds, :period => :day)
        insights.options.should == {
          :connection_scope => 'page_like_adds/day',
          :access_token => 'access_token'
        }
        insights.first.should == FbGraph::Insight.new(
          '117513961602338/insights/page_like_adds/day',
          :access_token => 'access_token',
          :name => 'page_like_adds',
          :description => 'Daily Likes of your Page\'s content (Total Count)',
          :period => 'day',
          :values => [{
            :value => 1,
            :end_time => '2010-12-09T08:00:00+0000'
          }, {
            :value => 1,
            :end_time => '2010-12-10T08:00:00+0000'
          }, {
            :value => 1,
            :end_time => '2010-12-11T08:00:00+0000'
          }]
        )
      end
    end
  end

end
