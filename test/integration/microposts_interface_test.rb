require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  # def setup
  #   @user = users(:michael)
  # end

  test "返信すると投稿者自身、返信先ユーザ、投稿者をフォローしているユーザのフィードだけにその投稿が表示されているか" do
    # テストユーザ取得
    #   michael (返信元ユーザ)
    #   archer  (返信先ユーザ)
    #   lana    (返信元ユーザをフォローしているユーザ)
    #   john    (返信元ユーザをフォローしていないユーザ)
    from_user   = users(:michael)
    to_user     = users(:archer)
    other_user1 = users(:lana)
    other_user2 = users(:john)

    # 返信先ユーザのunique_name取得
    unique_name = to_user.unique_name

    # 返信の内容
    content = "@#{unique_name} 結合テストで返信テスト"

    # 返信元ユーザでログイン
    log_in_as(from_user)

    # 返信を投稿
    post microposts_path, params: { micropost: { content: content } }

    # 投稿のid取得
    micropost_id = from_user.microposts.first.id

    # 返信元ユーザのフィードに返信の投稿がある
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # 返信先ユーザのフィードに返信の投稿がある
    log_in_as(to_user)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # 返信元ユーザをフォローしているユーザのフィードに返信の投稿がある
    log_in_as(other_user1)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content

    # 返信元ユーザをフォローしていないユーザのフィードに返信の投稿がない
    log_in_as(other_user2)
    get root_path
    assert_no_match "micropost-#{micropost_id}", response.body
  end

end
