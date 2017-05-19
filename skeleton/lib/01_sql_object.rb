require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.columns
    return @columns if @columns
    colms = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL

    colms.map!(&:to_sym)
    @columns = colms
  end

  def self.finalize!

    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end

    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(results).first
  end

  def initialize(populate_val = {})
    populate_val.each do |column, value|
      column = column.to_sym
      if self.class.columns.include?(column)
        self.send("#{column}=", value)
      else
        raise "unknown attribute '#{column}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) }
  end

  def insert



  end

  def update

  end

  def save
    id.nil? ? insert : update
  end
end
