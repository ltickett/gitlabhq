# frozen_string_literal: true

module Clusters
  module Gcp
    module Kubernetes
      class CreateOrUpdateNamespaceService
        def initialize(cluster:, kubernetes_namespace:)
          @cluster = cluster
          @kubernetes_namespace = kubernetes_namespace
          @platform = cluster.platform
        end

        def execute
          configure_kubernetes_namespace
          create_project_service_account
          configure_kubernetes_token

          kubernetes_namespace.save!
        rescue ::Kubeclient::HttpError => err
          raise err unless err.error_code = 404
        end

        private

        attr_reader :cluster, :kubernetes_namespace, :platform

        def configure_kubernetes_namespace
          kubernetes_namespace.configure_predefined_credentials
        end

        def create_project_service_account
          Clusters::Gcp::Kubernetes::CreateServiceAccountService.namespace_creator(
            platform.kubeclient,
            service_account_name: kubernetes_namespace.service_account_name,
            service_account_namespace: kubernetes_namespace.namespace,
            rbac: platform.rbac?
          ).execute
        end

        def configure_kubernetes_token
          kubernetes_namespace.service_account_token = fetch_service_account_token
        end

        def fetch_service_account_token
          Clusters::Gcp::Kubernetes::FetchKubernetesTokenService.new(
            platform.kubeclient,
            kubernetes_namespace.token_name,
            kubernetes_namespace.namespace
          ).execute
        end
      end
    end
  end
end
