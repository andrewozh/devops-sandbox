import React, { useState, useEffect } from 'react';
import Layout from '@theme/Layout';
import styles from './demo.module.css';

type OSInfo = {
  name: string;
  color: 'green' | 'orange' | 'red';
  message: string;
  icon: string;
};

const getOSInfo = (): OSInfo => {
  const userAgent = window.navigator.userAgent;
  const platform = window.navigator.platform;
  
  if (userAgent.includes('Mac') || platform.includes('Mac')) {
    return {
      name: 'macOS',
      color: 'green',
      message: 'Your OS is supported for local demo',
      icon: '🍎'
    };
  } else if (userAgent.includes('Linux') || platform.includes('Linux')) {
    return {
      name: 'Linux',
      color: 'orange',
      message: 'Local demo not tested on your OS',
      icon: '🐧'
    };
  } else if (userAgent.includes('Win') || platform.includes('Win')) {
    return {
      name: 'Windows',
      color: 'orange',
      message: 'Local demo not tested on your OS',
      icon: '🪟'
    };
  } else if (userAgent.includes('iPhone') || userAgent.includes('iPad')) {
    return {
      name: 'iOS',
      color: 'red',
      message: 'You can\'t run local demo on your OS',
      icon: '📱'
    };
  } else if (userAgent.includes('Android')) {
    return {
      name: 'Android',
      color: 'red',
      message: 'You can\'t run local demo on your OS',
      icon: '🤖'
    };
  } else {
    return {
      name: 'Unknown',
      color: 'red',
      message: 'You can\'t run local demo on your OS',
      icon: '❓'
    };
  }
};

export default function Demo(): JSX.Element {
  const [osInfo, setOSInfo] = useState<OSInfo | null>(null);

  useEffect(() => {
    setOSInfo(getOSInfo());
  }, []);

  return (
    <Layout
      title="Demo"
      description="DevOps Sandbox Demo">
      <div className={styles.container}>
        <h1 className={styles.title}>DevOps Sandbox Demo</h1>
        
        {osInfo && (
          <div className={`${styles.notification} ${styles[osInfo.color]}`}>
            <span className={styles.osIcon}>{osInfo.icon}</span>
            <span className={styles.osName}>{osInfo.name}</span>
            <span className={styles.separator}>|</span>
            <span className={styles.message}>{osInfo.message}</span>
          </div>
        )}
      </div>
    </Layout>
  );
}
