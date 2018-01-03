class TicketGroupsController < ApplicationController
  load_and_authorize_resource :conference, find_by: :short_title

  def show
    @primary_group = @conference.ticket_groups.first
    if @primary_group.blank?
      redirect_to conference_tickets_path(@conference.short_title)
    else
      @tickets = Ticket.visible_group_tickets(@primary_group)
    end
  end


end
