class DaySchedule

  attr_accessor :conference
  attr_accessor :room
  attr_accessor :event

  attr_accessor :interval_start
  attr_accessor :span

  def initialize(conference_id, day, interval)
    @conference_id = conference_id
    @day = day
    @interval = interval
  end

  def fetch
    ActiveRecord::Base.connection.execute("SELECT conference_id, interval_start, room_id, event_id, span
      FROM get_days_schedule(#{@conference_id}, '#{@day}'::timestamp, #{@interval})")
  end

  def save(validate = true)
    validate ? valid? : true
  end
end
