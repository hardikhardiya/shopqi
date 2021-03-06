# encoding: utf-8
class Admin::PagesController < Admin::AppController
  prepend_before_filter :authenticate_user!
  layout 'admin'
  before_filter :set_locale

  expose(:shop) { current_user.shop}
  expose(:pages) { current_user.shop.pages }
  expose(:page)

  expose(:blogs) { current_user.shop.blogs }
  expose(:blog)
  expose(:articles)
  expose(:comments){ shop.comments }

  def create
    if page.save
      redirect_to page_path(page)
    else
      render action: 'new'
    end
  end

  def update
    page.save
    flash.now[:notice] = I18n.t("flash.actions.#{action_name}.notice")
    respond_to do |format|
      format.html { redirect_to page_path(page) }
      format.js { render :template => "shared/msg" }
    end
  end

  def destroy
    page.destroy
    respond_to do |format|
      format.js { render template: "admin/pages/destroy" }
    end
  end

  def set_locale
    I18n.locale = params[:locale] if params[:locale].present? 
  end
end
