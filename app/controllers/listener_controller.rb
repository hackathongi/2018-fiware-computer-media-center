class ListenerController < ApplicationController
  #  skip_before_action :protect_from_forgery
  skip_before_action :verify_authenticity_token

  def on_event
    Rails.logger.info ">>>>>>>>>>>>>>>>>>>"
    entity_id= params[:entity_id]
    Rails.logger.info "Invoking entity: #{entity_id}"
    params.permit!
    data= params[:data]
    Rails.logger.info "with params: #{data}"
    attr= find_attr(data.first)
    Rails.logger.info "attribute: #{attr}"

    send(:"#{entity_id}_#{attr[:name]}", attr[:value])

    Rails.logger.info ">>>>>>>>>>>>>>>>>>>"
    head :ok
  end

  #----------------------------------------
  private
  #----------------------------------------

  def computer_search(value)
    return if value == 'none'
    cmd= %Q[/usr/bin/firefox -search "#{value}"]
    Rails.logger.info "EXECUTING CMD: #{cmd}"
    %x[#{cmd}]
  end
  def computer_play(value)
    return if value == 'none'
    player= Player.new
    player.play(value)
  end

  def find_attr(data)
    keys= data.keys - ['id', 'type', 'metadata']
    #    puts "should be 1 key: #{keys}"
    key= keys.first
    {name: key, value: data[key]['value']}
  end
end
