require  "spec_helper"
describe ClassInheritable::Array do
  let(:some_class) { Class.new(Object) }
  let(:some_class_expected_methods) {
    base_name = ClassInheritable::Array::DEFAULT_ARRAY_NAME
    [ "#{base_name}=", "append_#{base_name}", base_name ].map(&:to_sym)
  }

  context "initialization" do
    context "without valid params" do
      it "should raise an error" do
        expect { ClassInheritable::Array.new }.to raise_error(ArgumentError)
      end

      context "with invalid params" do
        it "should raise an error" do
          expect { ClassInheritable::Array.new( ClassInheritable::Array ) }.to raise_error(ArgumentError)
          expect { ClassInheritable::Array.new( Class.new( ClassInheritable::Array ) ) }.to raise_error(ArgumentError)
        end
      end
    end

    context "with valid params" do
      it "should not raise an error" do
        expect { ClassInheritable::Array.new( some_class ) }.not_to raise_error
      end
    end
  end

  context "attachment" do
    context "without valid params" do
      it "should raise an error" do
        expect { ClassInheritable::Array.attach }.to raise_error(ArgumentError)
      end

      context "with invalid params" do
        it "should raise an error" do
          expect { ClassInheritable::Array.class_eval { ClassInheritable::Array.attach {} } }.to raise_error
        end
      end
    end

    context "with valid params" do
      it "should not raise an error" do
        expect { some_class.class_eval { ClassInheritable::Array.attach {} } }.not_to raise_error
        expect { ClassInheritable::Array.attach :to => some_class }.not_to raise_error
      end

      it "should attach expected methods and variables to some class" do
        ( some_class.methods - Object.methods ).should eq( [] )
        ClassInheritable::Array.attach :to => some_class
        ( some_class.methods - Object.methods ).should eq( some_class_expected_methods )
      end

      context "with params that override attribute and method name(s) on a base class" do
        let(:as) { :required_items }
        let(:writer) { :only_require_item }
        let(:appender) { :require_item }
        let(:method_names) { [ writer, appender, as ] }
        let(:base_class) {
          _as = as; _appender = appender; _writer = writer
          Class.new(Object).tap do |_base_class|
            _base_class.class_eval do
              ClassInheritable::Array.attach(
                :as => _as,
                :appender_name => _appender,
                :writer_name => _writer
              ) {}
              def expected_items
                []
              end
            end
          end
        }

        it "should add expected attribute and methods to that base class" do
          ( base_class.methods - Object.methods ).should eq( method_names )
          base_class.instance_variables.should == [ "@#{as}".to_sym ]
        end

        let(:base_class_instance) { base_class.new }
        it "should return expected items from base_class instances" do
          base_class_instance.required_items.should == base_class_instance.expected_items
        end


        context "with multiple arrays on a class" do
          let(:subclass_of_base_class) {
            Class.new(base_class).tap do |_subclass_of_base_class|
              _subclass_of_base_class.class_eval do
                ClassInheritable::Array.attach {}
                append_class_inheritable_array [ :cia_1, :cia_2 ]
                require_item :subclass_of_base_class
              end
            end
          }
          it "should maintain both arrays" do
            subclass_of_base_class.required_items.should == [:subclass_of_base_class]
            subclass_of_base_class.class_inheritable_array.should == [:cia_1, :cia_2]
          end
          it "should add new methods to the child but not its parent class" do
            some_class_expected_methods.each do |subclass_method|
              subclass_of_base_class.should respond_to( subclass_method )
              base_class.should_not respond_to( subclass_method )
            end
          end
        end

        context "given subclasses (of the base class) with appended items" do
          let(:subclass_a) {
            Class.new(base_class).tap do |_subclass_a|
              _subclass_a.class_eval do
                require_item :subclass_a
                def expected_items
                  [:subclass_a]
                end
              end
            end
          }
          let(:subclass_a_instance) { subclass_a.new }

          let(:subclass_b) {
            Class.new(base_class).tap do |_subclass_b|
              _subclass_b.class_eval do
                require_item :subclass_b
                def expected_items
                  [:subclass_b]
                end
              end
            end
          }
          let(:subclass_b_instance) { subclass_b.new }

          it "should return all items in this (sub)class's hierarcy for this array" do
            subclass_a.required_items.should == subclass_a_instance.expected_items
            subclass_b.required_items.should == subclass_b_instance.expected_items
          end

          it "should return all items in an instance of this (sub)class's hierarcy for this array" do
            subclass_a_instance.required_items.should == subclass_a_instance.expected_items
            subclass_b_instance.required_items.should == subclass_b_instance.expected_items
          end

          context "given sub-subclasses" do
            context "with overriden items" do
              let(:sub_base_a) {
                Class.new(subclass_a).tap do |_sub_base_a|
                  _sub_base_a.class_eval do
                    only_require_item :sub_base_a
                    def expected_items
                      [:sub_base_a]
                    end
                  end
                end
              }
              let(:sub_base_a_instance) { sub_base_a.new }

              it "should ignore this (sub)class's parent's items" do
                sub_base_a.required_items.should == sub_base_a_instance.expected_items
              end

              it "should ignore an instance of this (sub)class's parent's items" do
                sub_base_a_instance.required_items.should == sub_base_a_instance.expected_items
              end

              context "with a subsequent level of appended items" do
                let(:subclass_sub_base_a) {
                  Class.new(sub_base_a).tap do |_subclass_sub_base_a|
                    _subclass_sub_base_a.class_eval do
                      require_item :subclass_sub_base_a
                      def expected_items
                        [:sub_base_a, :subclass_sub_base_a]
                      end
                    end
                  end
                }
                let(:subclass_sub_base_a_instance) { subclass_sub_base_a.new }

                it "should ignore this (sub-sub)class's grand-parent's items" do
                  subclass_sub_base_a.required_items.should == subclass_sub_base_a_instance.expected_items
                end
                it "should ignore an instance of this (sub-sub)class's grand-parent's items" do
                  subclass_sub_base_a_instance.required_items.should == subclass_sub_base_a_instance.expected_items
                end
              end # overriden-then-extended
            end # overriden

            context "with more items appended" do
              let(:sub_subclass_b) {
                Class.new(subclass_b).tap do |_sub_subclass_b|
                  _sub_subclass_b.class_eval do
                    require_item :sub_subclass_b
                    def expected_items
                      [:subclass_b, :sub_subclass_b]
                    end
                  end
                end
              }
              let(:sub_subclass_b_instance) { sub_subclass_b.new }

              it "should include all items in this (sub-sub)class's hierarchy" do
                sub_subclass_b.required_items.should == sub_subclass_b_instance.expected_items
              end

              it "should include all items in an instance of this (sub-sub)class's hierarchy" do
                sub_subclass_b_instance.required_items.should == sub_subclass_b_instance.expected_items
              end
            end # more appended
          end # sub-subclasses
        end # subclasses
      end # overriden attr/methods
    end
  end
end
