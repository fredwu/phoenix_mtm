defmodule PhoenixMTM.HelpersTest do
  use ExUnit.Case
  use Plug.Test
  use PhoenixHTMLHelpers

  import Phoenix.HTML
  import PhoenixMTM.Helpers, only: [collection_checkboxes: 4, collection_checkboxes: 3]

  doctest PhoenixMTM.Helpers

  defp conn do
    Plug.Test.conn(:get, "/foo", %{})
  end

  describe "when passed the :nested option" do
    test "doesn't allow xss" do
      form =
        safe_to_string(
          form_for(conn(), "/", [as: :form], fn f ->
            collection_checkboxes(f, :collection, ["<script>alert()</script>": 1, "2": 2],
              nested: true,
              other_option: true
            )
          end)
        )

      refute form =~ ~s(<script>)
    end

    test "generates list of labels with a checkbox nested in each" do
      form =
        safe_to_string(
          form_for(conn(), "/", [as: :form], fn f ->
            collection_checkboxes(f, :collection, ["1": 1, "2": 2],
              nested: true,
              other_option: true
            )
          end)
        )

      assert form =~
               ~s(
          <label for=\"form_collection_1\">
            <input id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\">
            1
          </label>
          <label for=\"form_collection_2\">
            <input id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\">
            2
          </label>
        ) |> remove_outside_whitespace
    end
  end

  describe "when passed the :wrapper option" do
    test "wraps each label and input" do
      form =
        safe_to_string(
          form_for(conn(), "/", [as: :form], fn f ->
            collection_checkboxes(f, :collection, ["1": 1, "2": 2], wrapper: &content_tag(:p, &1))
          end)
        )

      assert form =~
               ~s(
          <p>
            <input id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\">
            <label for=\"form_collection_1\">1</label>
          </p>
          <p>
            <input id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\">
            <label for=\"form_collection_2\">2</label>
          </p>
        ) |> remove_outside_whitespace
    end
  end

  describe "when passed the :mapper option" do
    test "maps each label and input into a specified structure" do
      mapper = fn form, field, input_opts, label_content, label_opts, _opts ->
        content_tag(:div, class: "checkbox") do
          label(form, field, label_opts) do
            [
              tag(:input, input_opts),
              html_escape(label_content)
            ]
          end
        end
      end

      form =
        safe_to_string(
          form_for(conn(), "/", [as: :form], fn f ->
            collection_checkboxes(f, :collection, ["1": 1, "2": 2], mapper: mapper)
          end)
        )

      assert form =~
               ~s(
          <div class=\"checkbox\">
            <label for=\"form_collection_1\">
              <input id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\">
              1
            </label>
          </div>
          <div class=\"checkbox\">
            <label for=\"form_collection_2\">
              <input id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\">
              2
            </label>
          </div>
        ) |> remove_outside_whitespace
    end
  end

  test "generates list of checkboxes and inputs" do
    form =
      safe_to_string(
        form_for(conn(), "/", [as: :form], fn f ->
          collection_checkboxes(f, :collection, "1": 1, "2": 2)
        end)
      )

    assert form =~
             ~s(<input id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\"><label for=\"form_collection_1\">1</label><input id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\"><label for=\"form_collection_2\">2</label>)
  end

  test "generates list of checkboxes and inputs with a class" do
    form =
      safe_to_string(
        form_for(conn(), "/", [as: :form], fn f ->
          collection_checkboxes(f, :collection, ["1": 1, "2": 2],
            input_opts: [class: "form-field"]
          )
        end)
      )

    assert form =~
             ~s(<input class=\"form-field\" id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\"><label for=\"form_collection_1\">1</label><input class=\"form-field\" id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\"><label for=\"form_collection_2\">2</label>)
  end

  test "generates list of checkboxes and inputs with one selected element" do
    form =
      safe_to_string(
        form_for(conn(), "/", [as: :form], fn f ->
          collection_checkboxes(f, :collection, ["1": 1, "2": 2], selected: [1])
        end)
      )

    assert form =~
             ~s(<input checked id=\"form_collection_1\" name=\"form[collection][]\" type=\"checkbox\" value=\"1\"><label for=\"form_collection_1\">1</label><input id=\"form_collection_2\" name=\"form[collection][]\" type=\"checkbox\" value=\"2\"><label for=\"form_collection_2\">2</label>)
  end

  test "generates hidden input" do
    form =
      safe_to_string(
        form_for(conn(), "/", [as: :form], fn f ->
          collection_checkboxes(f, :collection, "1": 1, "2": 2)
        end)
      )

    assert form =~
             ~s(<input id=\"form_collection\" name=\"form[collection][]\" type=\"hidden\" value=\"\">)
  end

  def remove_outside_whitespace(string) do
    whitespace_not_inside_html_tag = ~r/\s(?=[^>]*(<|$))/
    String.replace(string, whitespace_not_inside_html_tag, "")
  end
end
