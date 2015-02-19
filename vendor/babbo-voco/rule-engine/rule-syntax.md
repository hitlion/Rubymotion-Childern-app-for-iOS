# Basic Syntax
A basic type definition uses the following syntax:

```json
"type_name" : {
    "type"   : "name-of-base-or-foundation-type",
    "constr" : <value>,
    "constr" : <value>,
    ...
    "constr" : <value>
}
```

```ruby
puts 'Hello world'
```

Where `type` must be an already existing type class (e.g. parsed before) or one
of the predefined foundation types valid in JSON.

For reference, the foundation types are:

- string
- integer
- float
- object
- array

These types are grouped into two distinct categories: _simple_ and _compound_.

## Simple Types
For the scope of this document all types without support for properties or nested
elements are considered _simple types_. This includes all foundation types except
for **object** and **array**.

A simple type can be identified just by looking up the native class it is mapped
to and by applying any defined constraints.

## Compound Types
A compound type is any type that provides support for arbitrary properties or
for nesting other types within itself. This currently applies to the **object**
and **array** foundation types.

### object
**object** is considered to be a compound since it allows for user defined
properties:

```json
"compound_object" : {
    "type" : "object",
    "properties" : {
        "prop1" : {
            "type"     : "name-of-existing-type",
            "optional" : <true|false>,
            "default"  : <optional default value>,
            "constr"   : <value>,
            ...
            "constr"   : <value>
        },
        ...
        "propN" : {
            ...
        }
    },
    "property_meta" : <optional name of property metatype>
}
```

The `properties` dictionary contains an arbitrary set of properties, each of
which being a type definition or type reference on it's own.

A property (like _prop1_ above) follows the same rules as other type definitions
but allows for two additional fields:

#### "optional"
  * indicates that this property can be omitted (defaults to **false**)

#### "default"
  * a default value for this property in case it is omitted
  * for this to work `optional` has to be **true**, however no error is
    generated if `optional` is **false** or unset and `default` is provided.

The optional `properties_meta` can be used to attach a so called _metatype_ to
the properties defined in this object. If an attempt is made to set a constraint
on a property that the type of this property does not support natively
it's _metatype_ will be checked for that constraint and used to apply it there
if supported.

### array
**array** is considered to be a compound since it allows for user defined item
types along with minimal and maximal count of items:

```json
"compound_array" : {
    "type" : "array",
    "items" : {
        "type" : "name-of-existing-type" || "ref" : "name-of-later-defined-type"
    },
    "min_items" : <minimal-count>,
    "max_items" : <maximal-count>
}
```

Each **array**-based type is allowed to contain one specific type of elements.
These elements are described inside the `items` property which currently supports
two sub keys: `type` and `ref`.

`type` as the name suggests is used to define the type of elements expected.
The used type name must be an already existing type.

`ref` works mostly in the same way as does `type` however it will not try to
lookup the type definition on the spot parsing the rules but will rather make a
"reference" to that type. References are only resolved once the whole ruleset was
parsed and at which point all types should be known.

In addition to this an **array**-based type can define a minimal (`min_items`)
and maximal (`max_items`) number of elements the array can contain.
Both of these properties are optional and if unset default to _0_ and _infinite_.

## Constraints

A type may have an arbitrary number of constrains applied to it.
A constraint defines how to validate values of that particular type and is also
used in type deduction and type identification when validating JSON files.

The following constraints are currently defined:

#### "pattern"
  * check the value against a regular expression
  * supported for types based on **string**

#### "enum"
  * check the value against a range of predefined values
  * supported for types based on **string**, **integer** and **float**

#### "min" / "max"
  * check the value against a fixed lower / upper bound
  * supported for types based on **integer** and **float**
  * each part of the range is optional i.e. a type can have `min` without `max`
    and vice versa

#### Expected Values as Constraints

In addition to the predefined constraints each *inherited* property that is
based on a simple type (integer, string, ...) can be set to an expected value.

If an expected value is set validation of an instance of this type will fail
unless the property with the expected value is actually set to that value.

Sample:

```json
  "base_object" : {
    "type" : "object",
    "properties" : {
      "name" : "string"
    }
  },

  "named_foo_object" : {
    "type" : "base_object",
    "name" : "foo"
    "properties" : { ... }
  }
```

In the above example an instance of the type `named_foo_object` will only validate
if it contains a property `name` which has the value `foo`.
This works since the `name` property was inherited from `base_object` wher it is
defined as the simple type **string**.

It's important to note that the property **must be inherited**.

## Defining the Validation Scope
In addition to the type definitions mentioned above each rule set should contain
one element defining the validation scope.

The validation scope describes the expected items contained in a JSON document
as follows:

```json
  "validate" : {
    "title" : "title-for-this-scope",
    "items" : [
      {
        "type": "type-of-expected-element",
        "optional" : <true|false>,
        "min_items": <expected lower bound (optional)>,
        "max_items": <expected upper bound (optional)>
      },
      {
        ...
      },
    ]
  }
```
A validation scope starts with a human readable `title` property which defines
the name of the scope.

In addition to the `title` property the actual contents of the validation
scope are defined inside the `items` property.

`items` is expected to be an array of dictionaries with each dictionary describing
one allowed toplevel type in the document. If a validation scope has multiple
elements inside `items` each of them is in turn used to try to validate the
JSON document. If one of the elements succeeds the JSON is considered valid.

The properties expected for any element inside the `items` array are as follows:

#### "type"
  * any previously defined or foundation type

#### "optional"
  * marks this element as optional or required
  * defaults to **false**

#### "min_items" / "max_items"
  * lower / upper bound for the number of expected occurrences of items of this
    type inside the validated document.
  * both properties are optional and default to _0_ and _infinite_ respectively
