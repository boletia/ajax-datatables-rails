module AjaxDatatablesRails
  class NotImplemented < StandardError; end

  class Base
    extend Forwardable
<<<<<<< HEAD
    include ActiveRecord::Sanitization::ClassMethods
    class MethodNotImplementedError < StandardError; end
=======
>>>>>>> v-0-4-0

    attr_reader :view, :options
    def_delegator :@view, :params, :params

    def initialize(view, options = {})
      @view = view
      @options = options
      load_orm_extension
    end

    def config
      @config ||= AjaxDatatablesRails.config
    end

    def datatable
      @datatable ||= Datatable::Datatable.new self
    end

    # Must overrited methods
    def view_columns
      fail(NotImplemented, view_columns_error_text)
    end

    def data
      fail(NotImplemented, data_error_text)
    end

    def get_raw_records
      fail(NotImplemented, raw_records_error_text)
    end

    def as_json
      {
        recordsTotal: total_records,
        recordsFiltered: filter_records,
        data: data
      }
    end

    def total_records
      get_raw_records.count(:all)
    end

    def filtered_records
      get_raw_records.model.from("(#{filter_records(get_raw_records).except(:limit, :offset, :order).to_sql}) AS foo").count
    end

    def records
      @records ||= retrieve_records
    end

    # helper methods
    def searchable_columns
      @searchable_columns ||= begin
        connected_columns.select &:searchable?
      end
    end

    def search_columns
      @search_columns ||= begin
        searchable_columns.select { |column| column.search.value.present? }
      end
    end

    def connected_columns
      @connected_columns ||= begin
        view_columns.keys.map do |field_name|
          datatable.column_by(:data, field_name.to_s)
        end.compact
      end
    end

    private
    # view_columns can be an Array or Hash. we have to support all these formats of defining columns
    def connect_view_columns
      # @connect_view_columns ||= begin
      #   adapted_options =
      #     case view_columns
      #     when Hash
      #     when Array
      #       cols = {}
      #       view_columns.each_with_index({}) do |index, source|
      #         cols[index.to_s] = { source: source }
      #       end
      #       cols
      #     else
      #       view_columns
      #     end
      #   ActiveSupport::HashWithIndifferentAccess.new adapted_options
      # end
    end

    def retrieve_records
      records = fetch_records
      records = filter_records(records)
      records = sort_records(records)     if datatable.orderable?
      records = paginate_records(records) if datatable.paginate?
      records
    end

    # Private helper methods
    def load_orm_extension
      case config.orm
      when :mongoid then nil
      when :active_record then extend ORM::ActiveRecord
      else
        nil
      end
    end

<<<<<<< HEAD
    def new_search_condition(column, value)
      model, column = column.split('.')
      model = model.constantize
      casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [model.arel_table[column.to_sym].as(typecast)])
      casted_column.matches("%#{sanitize_sql_like(value)}%")
    end

    def deprecated_search_condition(column, value)
      model, column = column.split('.')
      model = model.singularize.titleize.gsub( / /, '' ).constantize

      casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [model.arel_table[column.to_sym].as(typecast)])
      casted_column.matches("%#{sanitize_sql_like(value)}%")
    end

    def aggregate_query
      conditions = searchable_columns.each_with_index.map do |column, index|
        value = params[:columns]["#{index}"][:search][:value] if params[:columns]
        search_condition(column, value) unless value.blank?
      end
      conditions.compact.reduce(:and)
    end

    def typecast
      case config.db_adapter
      when :oracle then 'VARCHAR2(4000)'  
      when :pg then 'VARCHAR'
      when :mysql2 then 'CHAR'
      when :sqlite3 then 'TEXT'
      end
    end

    def offset
      (page - 1) * per_page
    end

    def page
      (params[:start].to_i / per_page) + 1
    end

    def per_page
      params.fetch(:length, 10).to_i
    end

    def sort_column(item)
      new_sort_column(item)
    rescue
      ::AjaxDatatablesRails::Base.deprecated '[DEPRECATED] Using table_name.column_name notation is deprecated. Please refer to: https://github.com/antillas21/ajax-datatables-rails#searchable-and-sortable-columns-syntax'
      deprecated_sort_column(item)
    end

    def deprecated_sort_column(item)
      sortable_columns[sortable_displayed_columns.index(item[:column])]
    end
=======
    def raw_records_error_text
      return <<-eos

        You should implement this method in your class and specify
        how records are going to be retrieved from the database.
      eos
    end

    def data_error_text
      return <<-eos
>>>>>>> v-0-4-0

        You should implement this method in your class and return an array
        of arrays, or an array of hashes, as defined in the jQuery.dataTables
        plugin documentation.
      eos
    end

    def view_columns_error_text
      return <<-eos

        You should implement this method in your class and return an array
        of database columns based on the columns displayed in the HTML view.
        These columns should be represented in the ModelName.column_name,
        or aliased_join_table.column_name notation.
      eos
    end
  end
end
