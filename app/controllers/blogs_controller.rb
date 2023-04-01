# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    redirect_if_permission_error if current_user != @blog.user && @blog.secret
  end

  def new
    @blog = Blog.new
  end

  def edit
    redirect_if_permission_error if @blog.user != current_user
  end

  def create
    blog_params[:random_eyecatch] = false unless current_user.premium
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_if_permission_error if @blog.user != current_user
    blog_params[:random_eyecatch] = false unless current_user.premium

    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_if_permission_error if @blog.user != current_user
    @blog.destroy!
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def redirect_if_permission_error
    flash[:alert] = '権限がありません'
    redirect_to root_path
  end
end
