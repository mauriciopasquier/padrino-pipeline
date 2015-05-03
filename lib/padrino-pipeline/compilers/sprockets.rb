module Padrino
  module Pipeline
    module Compiler
      class Sprockets
        def initialize(config)
          @config = config
        end

        def compile(type)
          create_directory(@config.compiled_output)
          create_directory("#{@config.compiled_output}/#{@config.js_compiled_output}")
          create_directory("#{@config.compiled_output}/#{@config.css_compiled_output}")
          return unless @config.app
          case type
          when :js  then compile_js
          when :css then compile_css
          else
            throw RuntimeError, "Can not compile #{type} asset"
          end
        end

        def clean(type)
          case type
          when :js  then clean_js
          when :css then clean_css
          else
            throw RuntimeError, "Can not compile #{type} asset"
          end
        end

        def js_output_path(file_name = '')
          output_path(@config.js_compiled_output).join(file_name)
        end

        def css_output_path(file_name = '')
          output_path(@config.css_compiled_output).join(file_name)
        end

        private
        def assets
          @config.app.assets
        end

        def output_path(directory_name)
          output_path = Pathname.new(@config.compiled_output).join(directory_name)
        end

        def compile_css
          compile_assets(:css, ['css', 'css.gz'])
        end

        def compile_js
          compile_assets(:js, ['js', 'js.gz'])
        end

        def clean_css
          clean_assets(:css, ['css', 'css.gz'])
        end

        def clean_js
          clean_assets(:js, ['js', 'js.gz'])
        end

        def compile_assets(type, extensions = [])
          unless (asset = assets[@config.send("#{type.to_s}_compiled_asset")]).nil?
            extensions.each do |ext|
              output_path = self.send("#{type.to_s}_output_path", "application-#{asset.digest}.#{ext}")
              asset.write_to output_path
            end
          end
        end

        def clean_assets(type, extensions = [])
          extensions.each do |ext|
            FileUtils.rm Dir.glob(self.send("#{type.to_s}_output_path") + "application-*.#{ext}")
          end
        end

        def create_directory(path)
          FileUtils.mkdir_p(path)
        end
      end
    end
  end
end
