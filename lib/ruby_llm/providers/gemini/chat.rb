# frozen_string_literal: true

module RubyLLM
  module Providers
    module Gemini
      # Chat methods for the Gemini API implementation
      module Chat # rubocop:disable Metrics/ModuleLength
        # Must be public for Provider to use
        def complete(messages, tools:, temperature:, model:, api_key: nil, &block) # rubocop:disable Metrics/MethodLength
          payload = {
            contents: format_messages(messages),
            generationConfig: {
              temperature: temperature
            }
          }

          payload[:tools] = format_tools(tools) if tools.any?

          # Store tools for use in generate_completion
          @tools = tools

          if block_given?
            stream_completion(model, payload, api_key, &block)
          else
            generate_completion(model, payload, api_key)
          end
        end

        # Format methods can be private
        private

        def generate_completion(model, payload, api_key = nil)
          url = "models/#{model}:generateContent"
          response = post(url, payload, api_key)
          result = parse_completion_response(response)

          # If this contains a tool call, log it
          result.tool_calls.values.first if result.tool_call?

          result
        end

        def format_messages(messages)
          messages.map do |msg|
            {
              role: format_role(msg.role),
              parts: format_parts(msg)
            }
          end
        end

        def format_role(role)
          case role
          when :assistant then 'model'
          when :system, :tool then 'user' # Gemini doesn't have system, use user role, function responses use user role
          else role.to_s
          end
        end

        def format_parts(msg) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          if msg.tool_call?
            # Handle function calls
            [{
              functionCall: {
                name: msg.tool_calls.values.first.name,
                args: msg.tool_calls.values.first.arguments
              }
            }]
          elsif msg.tool_result?
            # Handle function responses
            [{
              functionResponse: {
                name: msg.tool_call_id,
                response: {
                  name: msg.tool_call_id,
                  content: msg.content
                }
              }
            }]
          elsif msg.content.is_a?(Array)
            # Handle multi-part content (text, images, etc.)
            msg.content.map { |part| format_part(part) }
          else
            # Simple text content
            [{ text: msg.content.to_s }]
          end
        end

        def format_part(part) # rubocop:disable Metrics/MethodLength
          case part[:type]
          when 'text'
            { text: part[:text] }
          when 'image'
            Media.format_image(part)
          when 'pdf'
            Media.format_pdf(part)
          when 'audio'
            Media.format_audio(part)
          else
            { text: part.to_s }
          end
        end

        def parse_completion_response(response)
          data = response.body
          tool_calls = extract_tool_calls(data)

          Message.new(
            role: :assistant,
            content: extract_content(data),
            tool_calls: tool_calls,
            input_tokens: data.dig('usageMetadata', 'promptTokenCount'),
            output_tokens: data.dig('usageMetadata', 'candidatesTokenCount'),
            model_id: data['modelVersion'] || response.env.url.path.split('/')[3].split(':')[0]
          )
        end

        def extract_content(data) # rubocop:disable Metrics/CyclomaticComplexity
          candidate = data.dig('candidates', 0)
          return '' unless candidate

          # Content will be empty for function calls
          return '' if function_call?(candidate)

          # Extract text content
          parts = candidate.dig('content', 'parts')
          text_parts = parts&.select { |p| p['text'] }
          return '' unless text_parts&.any?

          text_parts.map { |p| p['text'] }.join
        end

        def function_call?(candidate)
          parts = candidate.dig('content', 'parts')
          parts&.any? { |p| p['functionCall'] }
        end
      end
    end
  end
end
