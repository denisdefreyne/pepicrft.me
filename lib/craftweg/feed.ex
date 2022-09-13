defmodule Craftweg.Feed do
  @doc """
  Given a list of posts, it returns the content of the RSS feed to be
  returned by the controller function that handles the RSS feed request.
  """
  @spec generate(list(%Craftweg.Blog.Post{})) :: any
  def generate(posts) do
    %{ title: title, description: description, language: language, base_url: base_url} = Application.fetch_env!(:craftweg, :metadata)

    channel =
      RSS.channel(
        title,
        base_url |> URI.to_string,
        description,
        Timex.now() |> Timex.format!("{RFC1123}"),
        language
      )

    items = posts |> Enum.map(fn post ->
      post_url = %{ base_url | path: post.slug } |> URI.to_string
      guid = %{ base_url | path: post.old_slug } |> URI.to_string
      content = post.body
      pub_date = post.date |> Timex.to_datetime("Europe/Berlin") |> Timex.format!("{RFC822}")
      """
      <item>
        <title>#{post.title}</title>
        <description><![CDATA[#{post.description}]]></description>
        <author>hola@craftweg.com</author>
        <pubDate>#{pub_date}</pubDate>
        <link href="#{post_url}" type="text/html"/>
        <guid>#{guid}</guid>
        <content><![CDATA[#{post.body}]]></content>
      </item>
      """

# <published>2022-09-07T00:00:00+00:00</published>
# <updated>2022-09-07T00:00:00+00:00</updated>
# <link href="https://craftweg.com/blog/laying-out-a-project-foundation/" type="text/html"/>
# <id>https://craftweg.com/blog/laying-out-a-project-foundation/</id>
    end)
    feed = RSS.feed(channel, items)
    feed
  end
end
