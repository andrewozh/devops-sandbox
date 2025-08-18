import React from 'react';
import Layout from '@theme/Layout';

export default function Demo(): JSX.Element {
  return (
    <Layout
      title="Demo"
      description="Interactive Kubernetes playground">
      <div style={{ padding: '20px' }}>
        <h1>Kubernetes Playground Demo</h1>
        <p>This is an interactive Kubernetes playground powered by Killercoda.</p>
        <div style={{ 
          width: '100%', 
          height: '80vh', 
          border: '1px solid #ccc',
          borderRadius: '8px',
          overflow: 'hidden'
        }}>
          <iframe
            src="https://killercoda.com/playgrounds/scenario/kubernetes"
            width="100%"
            height="100%"
            style={{ border: 'none' }}
            title="Kubernetes Playground"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
      </div>
    </Layout>
  );
}
