import React from 'react';
import Layout from '@theme/Layout';
import styles from './demo.module.css';

export default function Demo(): JSX.Element {
  return (
    <Layout
      title="Demo"
      description="DevOps Sandbox Demo">
      <div className={styles.container}>
        <h1 className={styles.title}>DevOps Sandbox Demo</h1>
      </div>
    </Layout>
  );
}
