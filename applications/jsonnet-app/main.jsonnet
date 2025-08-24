// Jsonnet-based Application Library  
// Reads configuration files in hierarchical order with proper override support

// Get parameters from ArgoCD (via extVars)
local cloud = std.extVar('cloud');
local account = std.extVar('account'); 
local environment = std.extVar('environment');

// Configuration file hierarchy (most general to most specific)
// Files are in repo root, so we need to go up two levels from applications/jsonnet-app/
local configFiles = [
  '../../global.yaml',
  '../../%s.yaml' % cloud,
  '../../%s.yaml' % account,
  '../../%s.yaml' % environment,
  '../../%s-%s.yaml' % [cloud, account],
  '../../%s-%s.yaml' % [cloud, environment], 
  '../../%s-%s.yaml' % [account, environment],
  '../../%s-%s-%s.yaml' % [cloud, account, environment]
];

// Helper function to safely read YAML files with dynamic existence check
local safeReadYaml(file) = 
  if std.native('fileExists')(file) then
    std.parseYaml(std.native('readFile')(file))
  else
    {};

// Read all configuration files using the dynamic list
local configs = [safeReadYaml(file) for file in configFiles];

// Merge configurations with proper override (later configs override earlier ones)
local finalConfig = std.foldl(function(acc, config) acc + config, configs, {});

// Generate Kubernetes resources based on configuration
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'jsonnet-app-config',
    namespace: finalConfig.namespace,
    labels: {
      app: 'jsonnet-app',
      cloud: cloud,
      account: account,
      environment: environment,
    },
  },
  data: {
    'config.yaml': std.manifestYamlDoc(finalConfig),
    'cloud': cloud,
    'account': account,
    'environment': environment,
    // Include merged configuration for debugging
    'merged-config.json': std.manifestJsonEx(finalConfig, '  '),
  },
}
