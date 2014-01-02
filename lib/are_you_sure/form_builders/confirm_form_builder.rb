module AreYouSure
  class ConfirmFormBuilder < BaseFormBuilder

    def confirmation(options={})
      confirmed(true) +
      @template.content_tag(:p, options[:message] || I18n.t('helpers.submit.message_on_confirm', default: 'Are you sure?'))
    end

    def confirm_field(original_field, method, *options)
      field_value = fetch_field_value(original_field, method, *options)
      @template.content_tag(:p, field_value) +
      @template.hidden_field(@object_name, method)
    end

    def submit_or_confirm(options)
      cancel_value = options.delete(:cancel)
      submit + cancel(cancel_value)
    end

    def cancel(value)
      @template.link_to(value || I18n.t('helpers.submit.cancel', default: 'Cancel'), :back)
    end

    def method_missing(method, *args, &block)
      do_if_respond_to_original_method(method) do |original_method|
        send(:confirm_field, original_method, *args)
      end
    end

  private

    def fetch_field_value(original_field, method, *options)
      field_value = @object.send(method)
      case original_field
      when /collection/
        collection_field_value(field_value, *options)
      when /date|time/
        datetime_field_value(field_value, *options)
      when /select/
        select_field_value(field_value, *options)
      when /check/
        check_field_value(field_value, *options)
      else
        field_value
      end
    end

    def collection_field_value(selected, choices, value_method, text_method, *options)
      return '' unless selected
      choices.detect {|c| c.send(value_method) == selected }.send(text_method)
    end

    def datetime_field_value(datetime, *options)
      datetime
    end

    def select_field_value(selected, *options)
      return '' unless selected
      options.flatten.each_slice(2).to_a.detect {|i| i[1] == selected }[0]
    end

    def check_field_value(checked, *options)
      checked ? options[1] || 'checked' : options[2] || ''
    end
  end
end
