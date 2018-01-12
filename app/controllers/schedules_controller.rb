class SchedulesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index

  def show
    @rooms = @conference.venue.rooms if @conference.venue
    schedules = @program.selected_event_schedules
    unless schedules
      redirect_to events_conference_schedule_path(@conference.short_title)
    end

    @events_schedules = schedules
    @events_xml = schedules.map(&:event).group_by{ |event| event.time.to_date } if schedules
    @dates = @conference.start_date..@conference.end_date
    @tracks = @conference.program.tracks

    @step_minutes = EventType::LENGTH_STEP.minutes
    @conf_start = @conference.start_hour
    @conf_end = @conference.end_hour
    @conf_period = @conference.end_hour - @conf_start

    # the schedule takes you to today if it is a date of the schedule
    @current_day = @conference.current_conference_day
    @day = @current_day.present? ? @current_day : @dates.first
    return unless @current_day
    # the schedule takes you to the current time if it is beetween the start and the end time.
    @hour_column = @conference.hours_from_start_time(@conf_start, @conference.end_hour)

    @tzname = Time.now.in_time_zone(@conference.timezone).strftime('%Z')
  end

  def mobile
    @rooms = @conference.venue.rooms if @conference.venue
    schedules = @program.selected_event_schedules
    unless schedules
      redirect_to events_conference_schedule_path(@conference.short_title)
    end

    @events_schedules = schedules
    @events_xml = schedules.map(&:event).group_by{ |event| event.time.to_date } if schedules
    @dates = @conference.start_date..@conference.end_date
    @tracks = @conference.program.tracks

    @step_minutes = EventType::LENGTH_STEP.minutes
    @conf_start = @conference.start_hour
    @conf_end = @conference.end_hour
    @conf_period = @conference.end_hour - @conf_start

    # the schedule takes you to today if it is a date of the schedule
    @current_day = @conference.current_conference_day
    @day = @current_day.present? ? @current_day : @dates.first
    return unless @current_day
    # the schedule takes you to the current time if it is beetween the start and the end time.
    @hour_column = @conference.hours_from_start_time(@conf_start, @conference.end_hour)

    @tzname = Time.now.in_time_zone(@conference.timezone).strftime('%Z')
  end

  def today_events
    day = Time.find_zone(@conference.timezone).today
    @current_time = Time.current.in_time_zone(@conference.timezone)
    @today_event_schedules = []
    @today_event_schedules = @program.selected_event_schedules.where(
      start_time: day + @conference.start_hour.hours..@current_time + 2.hours) if @program.selected_schedule
    render partial: 'today_events'
  end

  def events
    @dates = @conference.start_date..@conference.end_date
    @tracks = @conference.program.tracks

    @events_schedules = @program.selected_event_schedules
    @events_schedules = [] unless @events_schedules

    @unscheduled_events = if @program.selected_schedule
                            @program.events.confirmed - @program.selected_schedule.events
                          else
                            @program.events.confirmed
                          end

    day = @conference.current_conference_day
    @tag = day.strftime('%Y-%m-%d') if day
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
