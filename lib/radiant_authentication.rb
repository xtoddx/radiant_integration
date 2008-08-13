module RadiantAuthentication

  def self.included kls
    kls.class_eval do

      def crypted_password= val
        write_attribute(:password, val)
      end

      def password_required?
        changes[:password]
      end

      def authenticated?(password)
        read_attribute('password') == encrypt(password)
      end

      def new_user_should_not_administer_radiant
        # These should be set exclusively in the radiant interface
        self.admin = false
        self.developer = false
      end

      def new_user_name_is_login
        # This makes the radint /admin/users view cleaner
        self.name ||= login
      end

      event :register do
        transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !u.password.blank?}
      end

      before_create :new_user_should_not_administer_radiant

    end
  end

end
