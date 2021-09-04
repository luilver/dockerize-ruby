require 'minitest/autorun'
require 'dockerize-ruby'

class DockerizeTest < Minitest::Test
  def test_dockerfile
    Dockerize.dockerfile
    assert_path_exists "./Dockerfile"
  end

  def test_dockercompose
    Dockerize.dockercompose
    assert_path_exists "./docker-compose.yml"
  end

  def test_true
    assert true
  end
end
