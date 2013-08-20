

module Scuttlebutt::Compiler

  class InterpreterBasis < Object

    attr_accessor :data

    # Create a new Interpreter
    def initialize(engine)
      @e    = engine
      @data = nil
    end

    private

    # TODO: loads of helpers and such

  end

end
