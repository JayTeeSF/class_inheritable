Attempt to duplicate the functionality of Rails' old class_inheritable_ary
without monkey-patching base-classes or polluting target classes with
unexpected methods/attributes

Basic use-case:
  irb -r "./lib/class_inheritable/array.rb"   
    class MyClass
       ClassInheritable::Array.attach :to => self, :as => :foo
       append_foo :bar
    end
    class MySubClass < MyClass
      append_foo :baz
    end

    [:bar] == MyClass.foo
    [:bar] == MyClass.new.foo

    [:bar, :baz] == MySubClass.foo
    [:bar, :baz] == MySubClass.new.foo

(See specs for more detailed use-cases.)
rspec ./spec/lib/class_inheritable/array_spec.rb
