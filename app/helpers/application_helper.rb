module ApplicationHelper
  include Heroicon::Engine.helpers

  def icon(name, **options)
    heroicon(name, options: { class: "w-4 h-4 inline-block #{options[:class]}" })
  end
end
